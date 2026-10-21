
CLASS ztm364_cl_islm_trip_type_912 DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.

 INTERFACES if_oo_adt_classrun .

 "! Determine trip type by LLM<br/>
 "! <br/>
 "! @parameter i_title | Trip title
 "! @parameter i_details | Details e.g. from a calendar entry
 "! @parameter i_islm_scenario | Name of an ISLM scenario of type GENAI
 "! @parameter e_response      | Summary provided by the LLM
 "! @parameter e_category | trip category. Name can be retrieved via {@link ZTM364_I_Trip_Type}
 "! @parameter e_startdate | Start date of the trip
 "! @parameter e_enddate | End date of the trip
 "! @parameter e_city | Destination of the trip
 "! @parameter e_country | Code of the country being visited
 METHODS get_trip_type IMPORTING i_title         TYPE string OPTIONAL
                                 i_details       TYPE string OPTIONAL
                                 i_islm_scenario TYPE aic_islm_scenario_id=>type
                       EXPORTING e_response      TYPE string
                                 e_category      TYPE ZTM364_I_Trip_Type-Type
                                 e_startdate     TYPE datn
                                 e_enddate       TYPE datn
                                 e_city          TYPE string
                                 e_country       TYPE string.

PROTECTED SECTION.
PRIVATE SECTION.

 TYPES: BEGIN OF ty_event_type,
          type        TYPE c LENGTH 2,
          description TYPE string,
        END OF ty_event_type,
        ty_event_types TYPE STANDARD TABLE OF ty_event_type WITH EMPTY KEY.

ENDCLASS.



CLASS ztm364_cl_islm_trip_type_912 IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.

 "abap cloud
 DATA intelligent_scenario TYPE aic_islm_scenario_id=>type.

 "select a scenario
 intelligent_scenario = 'ZTM364_REUSE_MINIMAL'.
 "intelligent_scenario = 'ZTM364_REUSE_MASK'.
 "intelligent_scenario = 'ZTM364_REUSE_TRANSL'.

 SELECT SINGLE name FROM ztm364_i_5_islm_scenarios_vh WHERE name = @intelligent_scenario
                                                                   INTO @DATA(valid_name).

 IF valid_name IS INITIAL.
   out->write( |{ intelligent_scenario } does not exist or| ).
   out->write( |does not have ABAP language version for cloud development.| ).
   EXIT.
 ENDIF.

 DATA response_text        TYPE string.

 DATA(trip_description) = 'Talks with Customer AG '.
 DATA(trip_text) = |Subject: Statusmeeting with Customer AG : RAP implementation at Customer AG \r\n| &
                  |\r\n| &
                  |Location:    Microsoft Teams Meeting; Walldorf, MR WDF77 H3.03 (12) (Video)\r\n| &
                  |\r\n| &
                  |Start:   Mon 12/10/2026 12:30\r\n| &
                  |End: Mon 12/10/2026 14:00\r\n| &
                  |\r\n| &
                  |Recurrence:  (none)\r\n| &
                  |\r\n| &
                  |Meeting Status:  Meeting organizer\r\n| &
                  |\r\n| &
                  |Organizer:   Doe, John\r\n| &
                  |Required Attendees:  Doe, John; Major, Mary\r\n| &
                  |Resources:   MR WDF77 H3.03 (12) (Video)\r\n| &
                  |\r\n| &
                  |Categories:  SAP internal event\r\n| &
                  |\r\n| &
                  |Topics: \r\n| &
                  |- Dicuss prices for next offer\r\n| &
                  |- List of customer tickets\r\n| &
                  |- Next steps|.

 get_trip_type( EXPORTING i_title        = CONV #( trip_description )
                         i_details          = trip_text
                         i_islm_scenario = intelligent_scenario
               IMPORTING e_response      = response_text
                         e_category      = DATA(trip_category)
                         e_enddate       = DATA(enddate)
                         e_startdate     = DATA(startdate)
                         e_country       = DATA(country)
                         e_city          = DATA(city)
                            ).

 out->write( |Trip Category: { trip_category }|  ).
 out->write( |response: { response_text }|  ).
 out->write( |start date: { startdate }|  ).
 out->write( |end date: { enddate }|  ).
 out->write( |Country: { country }|  ).
 out->write( |City: { city }|  ).

ENDMETHOD.

METHOD get_trip_type.
 "we use technical property names to avoid problems when
 "the LLM response is being translated
 TYPES:
   BEGIN OF t_trip_categorization,
     p1 TYPE string, "tripcategory
     p2 TYPE string, "summary
     p3 TYPE string, "country
     p4 TYPE string, "city
     p5 TYPE datn, "startdate
     p6 TYPE datn, "enddate
   END OF t_trip_categorization.

 DATA result_get_trip_type TYPE t_trip_categorization.
 DATA event_types          TYPE ty_event_types.
 DATA error_text           TYPE string.

 SELECT type, description FROM ZTM364_I_Trip_Type
   INTO CORRESPONDING FIELDS OF TABLE @event_types.

 TRY.

     DATA(prompt_string) = |Derive a trip category based on the given trip title: { i_title }| &&
                           |The following trip categories exist: { cl_abap_char_utilities=>cr_lf }|.

     LOOP AT event_types INTO DATA(event_type).
       prompt_string = |{ prompt_string }{ event_type-type } ({ event_type-description }) |.
     ENDLOOP.

     IF i_details IS NOT INITIAL.
       prompt_string = |{ prompt_string }Also use this more detailed information to derive the category|.
       prompt_string = |{ prompt_string }{ i_details }|.
     ENDIF.

     prompt_string = |{ prompt_string }Please provide two character code for the TripCategory.|.

     prompt_string = |{ prompt_string }and an provide if possible short summary of that trip (duration, participants, topics).|.

     prompt_string = |{ prompt_string }Do NOT wrap the response in markdown. Respond in valid JSON.{ cl_abap_char_utilities=>cr_lf }|.
     prompt_string = |{ prompt_string } The following properties are being used in the JSON. { cl_abap_char_utilities=>cr_lf }|
                  && |p1 contains the "TripCategory", p2 contains the "Summary", { cl_abap_char_utilities=>cr_lf }|
                  && |p3 contains the "Country", p4 contains the "City"  { cl_abap_char_utilities=>cr_lf }|
                  && |, p5 contains the "StartDate" , p6 contains the "EndDate".  { cl_abap_char_utilities=>cr_lf }|
                  && |\{ { cl_abap_char_utilities=>cr_lf }|
                  && |"p1" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |"p2" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |"p3" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |"p4" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |"p5" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |"p6" :"",{ cl_abap_char_utilities=>cr_lf }|
                  && |\}{ cl_abap_char_utilities=>cr_lf }|.


     DATA(api) = cl_aic_islm_orch_api_factory=>get( )->create_instance( islm_scenario = i_islm_scenario ).

     api->configure_templating( )->add_user_message( message = prompt_string ).

     FINAL(response) = api->execute( )->orchestration_result( )->completion( ).

     /ui2/cl_json=>deserialize( EXPORTING json        = response
                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                CHANGING  data        = result_get_trip_type ).

     "mapping back to readable property names
     e_category = result_get_trip_type-p1.
     e_response = result_get_trip_type-p2.
     e_country = result_get_trip_type-p3.
     e_city     = result_get_trip_type-p4.
     e_startdate = result_get_trip_type-p5.
     e_enddate = result_get_trip_type-p6.

   CATCH cx_aic_api_factory
         cx_aic_prompt_template
         cx_aic_completion_api
         cx_root INTO DATA(aic_exception).
     error_text = aic_exception->get_text( ).
     e_category = '##'.
     e_response = |Error occurred. \r\n { error_text }|.
 ENDTRY.
ENDMETHOD.

ENDCLASS.

