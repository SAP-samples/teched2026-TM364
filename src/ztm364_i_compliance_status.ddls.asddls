@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TM364 expense category value help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZTM364_I_COMPLIANCE_STATUS
  as select from ztm364_compl_st
{
        //      @UI.hidden: true
        //  key uuid,
        @Search.defaultSearchElement: true
        @ObjectModel.text.element: ['Description']
        @UI.textArrangement: #TEXT_SEPARATE
        @UI.lineItem: [{ position: 10, importance: #HIGH }]
  key   compliance_status as ComplianceStatus,
        @Search.defaultSearchElement: true
        @Search.fuzzinessThreshold: 0.8
        @Semantics.text: true
        @UI.lineItem: [{ position: 20, importance: #HIGH }]
        description as Description

}
