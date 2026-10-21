@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TM364 trip types value help'
@ObjectModel.dataCategory: #VALUE_HELP
define view entity ZTM364_I_Trip_Type
  as select from ztm364_trip_type
{
      @UI.hidden: true
  key uuid,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      type        as Type,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @UI.lineItem: [{ position: 20, importance: #HIGH }]
      description as Description

}
