codeunit 70140923 UAEFAFFileGenerationTest
{
    Subtype = Test;
    TestPermissions = Disabled;

    var 
        Assert : Codeunit Assert;
        ENUM_EMIRATES : Option AUD,UAE,SHJ,AJM,RAK,FJH,UAQ;
        ENUM_VATTYPE : Option Value,Adjustment;

    trigger OnRun()
    begin
        UAETestDXBSales(); //dubai
        UAETestAUHSales(); //abu dhabi
        UAETestFJRSales(); //Fujairah
        UAETestRAKSales(); //Ras Al Khaimah
        UAETestSHJSales(); //Sharjah
        UAETestAJNSales(); //Ajman
        UAETestUAQSales(); //Um al Quwain
    end;
    

    [Test]    
    procedure UAETestDXBSales()
    begin
        InitiateVATTransaction('VAT_DXB','VAT_5G', 25000);
        Assert.AreEqual( CalculateVATReturn(ENUM_EMIRATES::UAE, ENUM_VATTYPE::Value), (0.05 * 25000), 'The amounts do not match');
    end;

    [Test]
    procedure UAETestAUHSales()
    var
        myInt: Integer;
    begin
    
    end;

    [Test]
    procedure UAETestFJRSales()
    var
        myInt: Integer;
    begin
        
    end;

    [Test]
    procedure UAETestRAKSales()
    var
        myInt: Integer;
    begin
        
    end;

    [Test]
    procedure UAETestSHJSales()
    var
        myInt: Integer;
    begin
        
    end;

    [Test]
    procedure UAETestAJNSales()
    var
        myInt: Integer;
    begin
        
    end;

    [Test]
    procedure UAETestUAQSales()
    var
        myInt: Integer;
    begin
    end;
    
    local procedure InitiateVATTransaction(BusCode : code[20]; ProdCode : code[20]; TransactionAmount: Decimal)
    var
        Customer : Record Customer;
        GLAccount : Record "G/L Account";
    begin
        Customer.SETRANGE("VAT Bus. Posting Group", BusCode);
        GLAccount.SETRANGE("VAT Bus. Posting Group", BusCode);
        GLAccount.SETRANGE("VAT Prod. Posting Group" , ProdCode );

        Customer.FindFirst();
        GLAccount.FindFirst();        

        UAECreateAndPostSalesInvoice(Customer."No.",GLAccount."No.", TransactionAmount);
    end;

    local procedure UAECreateAndPostSalesInvoice(SellToCustomerNo : Code[20]; AccountCode : Code[20]; InvoiceAmount : Decimal)
    var
        SalesHeader: Record "Sales Header"; 
        SalesLine: Record "Sales Line";     
        SalesPost : Codeunit "Sales-Post";
    begin
        UAECreateSalesHeader(SalesHeader, SellToCustomerNo);
        UAECreateSalesLine(SalesHeader, SalesLine,AccountCode, InvoiceAmount);
        SalesPost.Run(SalesHeader);
    end;

    local procedure UAECreateSalesHeader(SalesHeader : Record "Sales Header"; SellToCustomerNo :Code[20])
    var
        Customer : Record Customer;
    begin 
        Customer.Get(SellToCustomerNo); //check for valid customer

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        salesheader.Validate("Sell-to Customer No.", SellToCustomerNo);
        SalesHeader.Insert(true);
    end;

    local procedure UAECreateSalesLine(SalesHeader : Record "Sales Header"; SalesLine : Record "Sales Line"; GLCode : Code[20]; InvoiceAmount:Decimal)
    var
        GLAccount : Record "G/L Account";
    begin
        GLAccount.Get(GLAccount); //check for valid account code

        SalesLine.FindLast();
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Line No." += 10000;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Validate(Amount, InvoiceAmount);
        SalesLine.Insert(true);
    end;    
    
    local procedure CalculateVATReturn(EmirateCode : Option AUD,UAE,SHJ,AJM,RAK,FJH,UAQ; valueType : Option Value,Adjustment) : Decimal
    var
        RetDecimalValue : Decimal;       
        UAEVATReturnTestPage : TestPage "UAE VAT Return";
    begin        
        UAEVATReturnTestPage.OpenView();
        UAEVATReturnTestPage.UAEStartDate.SetValue(01/01/2018);
        UAEVATReturnTestPage.UAEEndDate.SetValue(01/01/2015);
        UAEVATReturnTestPage."UAE Calculate".Invoke();      

        case ( EmirateCode ) of
            EmirateCode::AUD: begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment.AsDecimal();
                end;
            end;

            EmirateCode::UAE : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount2.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment2.AsDecimal();
                end;
            end;

            EmirateCode::SHJ : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount3.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment3.AsDecimal();
                end;
            end;

            EmirateCode::AJM : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount4.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment4.AsDecimal();
                end;
            end;

            EmirateCode::RAK : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount5.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment5.AsDecimal();
                end;
            end;

            EmirateCode::FJH : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount6.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment6.AsDecimal();
                end;
            end;

            emirateCode::UAQ : begin
                if ( valueType = valueType::Value) then begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAmount7.AsDecimal();
                end else begin
                    RetDecimalValue := UAEVATReturnTestPage.UAEAdjustment7.AsDecimal();
                end;
            end;
        end;          

        exit( RetDecimalValue );
    end;    

}
