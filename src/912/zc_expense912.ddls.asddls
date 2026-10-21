@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_EXPENSE912
  as projection on ZR_EXPENSE912
  association [1..1] to ZR_EXPENSE912 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  ExpenseDescription,
  Category,
  TransactionType,
  ReceiptDate,
  @Semantics: {
    amount.currencyCode: 'Currency'
  }
  Amount,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  Currency,
  UploadedReceiptMimetype,
  UploadedReceiptFilename,
  UploadedReceipt,
  _Trip : redirected to parent ZC_TRIP912,
  _BaseEntity
}
