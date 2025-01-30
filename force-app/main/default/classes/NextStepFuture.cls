/*
 * NextStepFuture Class Description:
 * 
 * Question 1: Create a future method that updates all account and opportunities next step to 'Meeting in the future'
 * Question 2: Create a method that inserts a big deal opportunity and updates the user role name to 'CRO'
 * 
 * Benefits of using future methods:
 * 
 * 1. Asynchronous Processing: Allows long-running operations to be handled in the background, freeing up resources.
 * 2. Governor Limit Management: Asynchronous methods have a separate set of limits, providing more flexibility.
 * 3. User Experience Enhancement: Improves responsiveness in user interfaces by offloading processes to the background.
 * 4. Mixed DML Operations Handling: Helps overcome Mixed DML errors by allowing updates on setup and non-setup objects.
 * 5. Enhanced Integration Capabilities: Useful for making callouts to external systems without blocking the user interaction.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
 * 
 * Note: The class below contains placeholders for implementing a future method to update accounts and opportunities.
 *       The accompanying test class 'AsynchronousTest' should also be updated to test this method.
 */
public with sharing class NextStepFuture {

    /**
     * Question 1
     * Create a future method that updates all Account and Opportunity records' Next Step fields to 'Meeting in the future'.
     * Account Next Step field is a custom field.
     * Opportunity Next Step field is a standard field.
     * Update the corresponding test class AsynchronousTest and test method nextStepFuture_testUpdateAllNextStep to cover this method.
     */
    @future
    public static void updateAllNextStep() {
        final String FUTURE_NEXT_STEP = 'Meeting in the future';

        // Query all Accounts and update their Next Step field
        List<Account> accounts = [SELECT Id, Next_Step__c FROM Account];
        for (Account acc : accounts) {
            acc.Next_Step__c = FUTURE_NEXT_STEP;
        }
        if (!accounts.isEmpty()) {
            update accounts;
        }

        // Query all Opportunities and update their Next Step field
        List<Opportunity> opportunities = [SELECT Id, NextStep FROM Opportunity];
        for (Opportunity opp : opportunities) {
            opp.NextStep = FUTURE_NEXT_STEP;
        }
        if (!opportunities.isEmpty()) {
            update opportunities;
        }
    }

    /**
     * Question 2
     * Create a method that inserts a big deal Opportunity and updates the user's role name to 'CRO'.
     * Note: Use a future method to handle the role update because of Mixed DML restrictions.
     */
    public static void createDealAndUpdateRole() {
        // Insert a big deal Opportunity
        Opportunity bigDeal = new Opportunity();
        insertBigDeal(bigDeal);

        // Get the current user's role ID
        String userRoleId = UserInfo.getUserRoleId();
        if (userRoleId == null) {
            // Create a new role named 'Test Role' since the user has no role
            UserRole testRole = new UserRole(Name = 'Test Role');
            insert testRole;
            userRoleId = testRole.Id; // Assign the new role ID for the update
        }
        // Call the future method to update the role name
        updateUserRoleNameAsync(new List<String>{userRoleId});
    }

    // Helper method to insert a big deal Opportunity
    private static void insertBigDeal(Opportunity opp) {
        opp.Amount = 1000000; // High value for the deal
        opp.Name = 'Big Deal'; // Name of the deal
        opp.StageName = 'Closed Won'; // Set to a winning stage
        opp.CloseDate = Date.today(); // Set close date to today

        insert opp; // Save the Opportunity
    }

    /**
     * Future method to update the user role name to 'CRO'.
     * Accepts a list of role IDs as input.
     */
    @future
    private static void updateUserRoleNameAsync(List<String> roleIds) {
        // Query the roles using the provided IDs
        List<UserRole> roles = [SELECT Id, Name FROM UserRole WHERE Id IN :roleIds];
        for (UserRole role : roles) {
            role.Name = 'CRO'; // Update the name to 'CRO'
        }

        if (!roles.isEmpty()) {
            update roles; // Perform the update
        }
    }
}