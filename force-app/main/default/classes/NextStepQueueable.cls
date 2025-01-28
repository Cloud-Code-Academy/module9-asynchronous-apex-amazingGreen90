public with sharing class NextStepQueueable {

    // Member variable to store the accounts
    private Map<Id, Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id, Account> accounts) {
        this.accounts = accounts; // Store the accounts in a member variable
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Query for up to 10 accounts with the Next Step populated
        List<Account> accountsToProcess = [SELECT Id, Next_Step__c FROM Account WHERE Next_Step__c != null LIMIT 10];

        // If there are any accounts, queue the job using System.enqueueJob
        if (!accountsToProcess.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>();
            for (Account acc : accountsToProcess) {
                accountMap.put(acc.Id, acc);
            }
            // Enqueue the job and pass the map of accounts to the job
            System.enqueueJob(new NextStepQueueable(accountMap));
        }
    }

    /*
     * Execute the queueable job
     */
    public void execute(QueueableContext context) {
        // Get the accounts from the member variable
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : this.accounts.values()) {
            // Remove the Next Step using the helper method
            removeNextStep(acc);
            accountsToUpdate.add(acc);
        }

        // Update the accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        // Get the opportunities related to the accounts
        List<Opportunity> opportunitiesToUpdate = [SELECT Id, NextStep FROM Opportunity WHERE AccountId IN :this.accounts.keySet() AND NextStep != null];

        // Remove the Next Step from the opportunities using the helper method
        for (Opportunity opp : opportunitiesToUpdate) {
            removeNextStep(opp);
        }

        // Update the opportunities
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }

        // Optionally, queue the job again to process more records, if needed
        enqueueJob();
    }

    // Helper method to remove the Next Step from an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step from an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}