@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_EXPENSE912
  as select from zexpense912 as Expense
  association to parent ZR_TRIP912 as _Trip on $projection.ParentUUID = _Trip.UUID
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  expense_description as ExpenseDescription,
  category as Category,
  transaction_type as TransactionType,
  receipt_date as ReceiptDate,
  @Semantics.amount.currencyCode: 'Currency'
  amount as Amount,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency as Currency,
  @Semantics.mimeType: true
  uploaded_receipt_mimetype as UploadedReceiptMimetype,
  uploaded_receipt_filename as UploadedReceiptFilename,
  @Semantics.largeObject: { mimeType: 'UploadedReceiptMimetype',   //case-sensitive
                      fileName: 'UploadedReceiptFilename',   //case-sensitive
                      acceptableMimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
                      contentDispositionPreference: #ATTACHMENT }
  uploaded_receipt          as UploadedReceipt,
  _Trip
}
