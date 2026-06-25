public class VFPageController {
 public String PDFData {get; set;}  
    public PageReference downloadPDF(){
    System.PageReference pageRef = new System.PageReference('/apex/actualpdfpage');

    //ensure pdf downloads and is assigned with defined name
    pageRef.getHeaders().put('content-disposition', 'attachment; filename=TestPDF.pdf');
 
    return pageRef;
}
}