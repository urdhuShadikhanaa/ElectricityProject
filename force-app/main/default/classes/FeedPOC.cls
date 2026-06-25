public with sharing class FeedPOC {
    
    public class FeedItem {
        public String title {get; set;}
        public String link {get; set;}
        public String pubDate {get; set;}
        public String description {get; set;}
    }
    
    public List<FeedItem> feeds {get; set;}
    
    public FeedPOC() {
        feeds = new List<FeedItem>();
        loadFeeds();
    }
    
    private void loadFeeds() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:NewsFeed'); // Named Credential
            req.setMethod('GET');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Dom.Document doc = res.getBodyDocument();
                
                for (Dom.XmlNode channel : doc.getRootElement().getChildElements()) {
                    if (channel.getName().toLowerCase() == 'channel') {
                        for (Dom.XmlNode item : channel.getChildElements()) {
                            if (item.getName().toLowerCase() == 'item') {
                                FeedItem f = new FeedItem();
                                for (Dom.XmlNode child : item.getChildElements()) {
                                    if (child.getName() == 'title') f.title = child.getText();
                                    if (child.getName() == 'link') f.link = child.getText();
                                    if (child.getName() == 'pubDate') f.pubDate = child.getText();
                                    if (child.getName() == 'description') f.description = child.getText();
                                }
                                feeds.add(f);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching feed: ' + e.getMessage());
        }
    }
}