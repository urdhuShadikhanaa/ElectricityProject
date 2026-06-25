/*
** Description: This class is used in FFA**
*/
public with sharing class Meter{
    public string ExistingMeterSerialNumber;
    public string ExistingMeterManufacturer;
    public string ExistingMeterModel;
    public string ExistingMeterYearOfManufacture;
    public string InstalledOnStream;
    public string MeterStatusCode;
    public string MeterType;
    public string MeterMechanism;
    public string MeterLinkCode;
    public integer MeterNumberOfDials;
    public string MeterImperialFlag;
    public string MeterLocationCode;
    public string MeterLocationNotes;
    public integer Qmax;
    public string Qmin;
    public string Qnom;
    public String PreviousMeterRead;
    public date DateInstalled;
    public string PrimaryFunction;
    public string PhysicalSize;
    public string MaterialType;
    public String MeterRead;
    public string PressureRead;
    public string Connectionsize;
    public string Connectiontype;
    
    public Meter(){}
}