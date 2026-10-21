
CLASS ztm364_cl_islm_trip_compl_912 DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.

 INTERFACES if_oo_adt_classrun .


 METHODS check_trip_compliance IMPORTING i_trip_category     TYPE char02
                                         i_trip_details      TYPE string OPTIONAL
                                         i_trip_expenses     TYPE string
                                         i_islm_scenario     TYPE aic_islm_scenario_id=>type
                                         i_show_grounding    TYPE abap_bool DEFAULT abap_false
                               EXPORTING e_response          TYPE string
                                         e_compliance_status TYPE char1.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ztm364_cl_islm_trip_compl_912 IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.
 DATA response_text TYPE string.
 DATA ints          TYPE aic_islm_scenario_id=>type VALUE 'ZTM364_REUSE_GROUND'.

 " 1. SELECT from CDS View
 SELECT SINGLE FROM zr_trip912
   FIELDS *
   WHERE  tripid = '4'
   INTO @DATA(trip).

 SELECT expense_description,
        category,
        transaction_type,
        receipt_date,
        amount,
        currency

   FROM zexpense912
   WHERE parent_uuid = @trip-uuid
   INTO TABLE @DATA(expenses).

 " 2. Serialize to JSON
 DATA(lv_json) = /ui2/cl_json=>serialize( data        = expenses
                                          compress    = abap_true
                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

 out->write( lv_json ).

 check_trip_compliance( EXPORTING i_trip_category     = trip-Type
                                  i_trip_details      = trip-Details
                                  i_trip_expenses     = lv_json
                                  i_islm_scenario     = ints
                                  i_show_grounding    = abap_false
                        IMPORTING e_response          = response_text
                                  e_compliance_status = DATA(status) ).

 out->write( |Compliance status: { status }|  ).
 out->write( |response: { response_text }|  ).
ENDMETHOD.

METHOD check_trip_compliance.
 TYPES: BEGIN OF t_compliance_type,
          compliance_status TYPE char1,
          summary           TYPE string,
        END OF t_compliance_type.

 DATA result_trip_compliance TYPE t_compliance_type.
 DATA error_text TYPE string.

 SELECT SINGLE description FROM ZTM364_I_Trip_Type
  WHERE Type = @i_trip_category
   INTO @DATA(trip_type_description).

 DATA(prompt_string) = |This is a trip of trip category \r\n{ trip_type_description } ({ i_trip_category }).|.
 prompt_string = prompt_string && |List of expenses:\r\n|.
 prompt_string = prompt_string && |{ i_trip_expenses }\r\n|.
 prompt_string = prompt_string && |Please check if all expenses fit to the travel policy.|.
 prompt_string = prompt_string && |Do NOT wrap the response in markdown. Respond in valid JSON.| && cl_abap_char_utilities=>cr_lf
                  && |\{ | && cl_abap_char_utilities=>cr_lf
                  && |"Summary" :"",| && cl_abap_char_utilities=>cr_lf
                  && |"Compliance_Status" :"",| && cl_abap_char_utilities=>cr_lf
                  && |\}| && cl_abap_char_utilities=>cr_lf.

 prompt_string  = prompt_string && |the statusfield can have the following values: \r\n|.
 prompt_string  = prompt_string && |compliant (C), non-compliant (N), manager-approval-needed (M) \r\n|.


 TRY.

     DATA(api) = cl_aic_islm_orch_api_factory=>get( )->create_instance( islm_scenario =  i_islm_scenario ).

     api->configure_templating( )->add_prompt_template( template_id  =  'SYSTEM_PROMPT'
                                                        message_type = aic_prompt_message_type=>user_message
                                                      ).
*
*        api->configure_templating( )->add_prompt_template( template_id  = 'ISLM_SYSTEMINPUT'
*                                                           message_type = aic_prompt_message_type=>system_role ).

     api->configure_templating(  )->add_user_message(
       EXPORTING
         message = prompt_string
*  RECEIVING
*    self    =
     ).


     api->configure_grounding( )->add_grounding_template(
                 template_id         = 'GROUNDING_QUERY'
*            template_parameters = VALUE #( ( name  = 'ISLM_OrgType'
*                                             value = grounding_hint ) )
                                                  ).

     " For demo purpose only: check the grounding module's output, i.e. check
     " which document has been retrieved by the grounding query
     FINAL(grounding_output) = api->execute(  )->grounding_result( )->output( ).

     FINAL(response) = api->execute( )->orchestration_result( )->completion( ).


     /ui2/cl_json=>deserialize(
       EXPORTING
         json             = response
         pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
       CHANGING
         data             = result_trip_compliance
     ).

     e_response = result_trip_compliance-summary .
     IF i_show_grounding = abap_true.
       e_response = e_response && |\r\n Grounding:\r\n| && grounding_output.
     ENDIF.
     e_compliance_status = result_trip_compliance-compliance_status.

   CATCH cx_aic_api_factory cx_aic_prompt_template cx_aic_completion_api INTO DATA(lx_previous2).
     error_text = lx_previous2->get_text(  ).
     e_compliance_status = 'E'.
     e_response = error_text.
   CATCH cx_root INTO DATA(my_exception).
     error_text = my_exception->get_text(  ).
     e_compliance_status = 'E'.
     e_response = error_text.
 ENDTRY.



ENDMETHOD.

ENDCLASS.


