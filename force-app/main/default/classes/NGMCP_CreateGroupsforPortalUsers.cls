public with sharing class NGMCP_CreateGroupsforPortalUsers implements Queueable{
    private List<User> userList;
    public NGMCP_CreateGroupsforPortalUsers(List<User> userList) {
        this.userList = userList;
    }
    public void execute(QueueableContext context){
        createGroupsAndAddMembers(userList);
    }
    /* ================================
       NEW: GROUP HANDLING
       ================================ */
    private static void createGroupsAndAddMembers(List<User> users) {

        Set<String> supplierGroups = new Set<String>();
        for (User u : users) {
            if (!String.isBlank(u.Supplier_Group__c)) {
                supplierGroups.add(u.Supplier_Group__c);
            }
        }
        if (supplierGroups.isEmpty()){
            return;
        } 

        Map<String, Id> groupByName = new Map<String, Id>();

        for (Group g : [
            SELECT Id, Name
            FROM Group
            WHERE Type = 'Regular'
            AND Name IN :supplierGroups WITH USER_MODE
        ]) {
            groupByName.put(g.Name, g.Id);
        }

        List<Group> groupsToInsert = new List<Group>();
        for (String sg : supplierGroups) {
            if (!groupByName.containsKey(sg)) {
               sg = (sg != null && sg.trim().length() > 40)? sg.trim().substring(0, 40) : (sg != null ? sg.trim() : null);
                groupsToInsert.add(
                    new Group(Name = sg, Type = 'Regular')
                );
            }
        }

        if (!groupsToInsert.isEmpty()) {
            Database.SaveResult[] results =
                    Database.insert(groupsToInsert, false);
            for (Group g : groupsToInsert) {
                groupByName.put(g.Name, g.Id);
            }
        }

        List<GroupMember> members = new List<GroupMember>();
        for (User u : users) {
            Id gid = groupByName.get(u.Supplier_Group__c);
            if (gid != null) {
                members.add(new GroupMember(
                    GroupId = gid,
                    UserOrGroupId = u.Id
                ));
            }
        }

        if (!members.isEmpty()) {
           Database.SaveResult[] results =
                    Database.insert(members, false);
        }
    }


}