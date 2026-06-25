public class FlowUserRowIndexer {

    @InvocableMethod(label='Index FlowUserRow')

    public static void index(List<FlowUserRow> rows) {

        // DO NOTHING

        // This method exists ONLY to make FlowUserRow visible to Flow

        System.debug('Indexing FlowUserRow: ' + rows);

    }

}