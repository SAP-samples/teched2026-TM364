@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTrip912'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TRIP912
  as select from ZTRIP912 as Trip
  composition [1..*] of ZR_EXPENSE912 as _Expense
{
  key uuid as UUID,
  trip_id as TripID,
  title as Title,
  details as Details,
  llm_response as LlmResponse,
  city as City,
  country as Country,
  start_date as StartDate,
  end_date as EndDate,
  type as Type,
  status as Status,
  islm_scenario as IslmScenario,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  _Expense
}
