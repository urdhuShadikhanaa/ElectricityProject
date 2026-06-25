public class FFAWorkingDaysCalculator {
   
    public static Date getBusinessTargetDate(Integer BusinessDaystoAdd){
        
        Integer Hourstoadd=0;
        if(BusinessDaystoAdd==3){
           Hourstoadd=72;
        }
        if(BusinessDaystoAdd==10){
           Hourstoadd=240;
        }
        
        Datetime createdDate = system.now();
        BusinessHours bh = [SELECT ID, Name, IsDefault, IsActive From BusinessHours WHERE IsDefault=true];
        Datetime dueDatetime = BusinessHours.add(bh.Id, createdDate, Hourstoadd*60*60*1000);
        date duedate=dueDatetime.date();
        date Startdate=createdDate.date();
        system.debug(Startdate+'======'+duedate);
        //It will be Never True ,For to increase the test class to get Holidays
        /*if(test.isRunningTest()){
            duedate=duedate+310;
        }
        List<Holiday> NGHolidays=[Select Name, ActivityDate From Holiday Where ActivityDate >= :Startdate AND ActivityDate <= :duedate];
        Integer HolidaysIncrement=0;
        if(!NGHolidays.isEmpty() ){
            for(Holiday HolidaysCount:NGHolidays){
            DateTime currDate = DateTime.newInstance(HolidaysCount.ActivityDate.year(), HolidaysCount.ActivityDate.month(), HolidaysCount.ActivityDate.day());
            string dayName=currDate.format('EEEE');
                if(dayName!='Saturday' || dayName!='Sunday'){
                HolidaysIncrement=HolidaysIncrement+1;
                }
            }
        }
        duedate=duedate+HolidaysIncrement;*/
        return duedate;
        
    }
}