public class MaximoResponseWrapper {
    public List<WorkOrder> member; // example list

    public class WorkOrder {
        public String wonum;
        public String description;
        public String status;
        public String siteid;
        public String assetnum;
        public String location;
    }
}