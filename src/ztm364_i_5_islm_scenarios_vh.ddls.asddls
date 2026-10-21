@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for ISLM scenarios'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZTM364_I_5_ISLM_SCENARIOS_VH
  as select from I_CustABAPObjDirectoryEntry
{
  key cast( ABAPObject as abap.char( 20 ) ) as name,
      ABAPPackage
}
where
       ABAPObjectType = 'INTS'
  and(
       ABAPObject     = 'ZTM364_REUSE_MINIMAL'
    or ABAPObject     = 'ZTM364_REUSE_TRANSL'
    or ABAPObject     = 'ZTM364_REUSE_MASK'
  )
