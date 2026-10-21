CLASS lhc_expense DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS set_extracted_data FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Expense~set_extracted_data.

ENDCLASS.

CLASS lhc_expense IMPLEMENTATION.

  METHOD set_extracted_data.
   DATA message_container    TYPE REF TO if_aic_message_container.
 DATA prompt               TYPE string.
 DATA intelligent_scenario TYPE aic_islm_scenario_id=>type.

 DATA update               TYPE TABLE FOR UPDATE zr_trip912\\Expense.
 DATA update_line          TYPE STRUCTURE FOR UPDATE zr_trip912\\Expense.

 "set the scenario to be used
 intelligent_scenario = 'ZTM364_REUSE_NO_ORCH'.

 " Read all parent UUIDs
 READ ENTITIES OF zr_trip912 IN LOCAL MODE
      ENTITY Expense BY \_Trip
      ALL FIELDS WITH
      CORRESPONDING #( keys )
      RESULT DATA(trips).

 READ ENTITIES OF zr_trip912 IN LOCAL MODE
      ENTITY Expense ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(expenses).

 DATA media_type TYPE aic_media_type=>type.

 LOOP AT expenses INTO DATA(expense).

   CASE expense-UploadedReceiptMimetype.
     WHEN 'image/jpeg'.
       media_type = aic_media_type=>image_jpeg.
     WHEN 'image/png'.
       media_type = aic_media_type=>image_png.
     WHEN 'image/webp'.
       media_type = aic_media_type=>image_webp.
     WHEN 'application/pdf'.
       media_type = aic_media_type=>document_pdf.
     WHEN OTHERS.
       ASSERT 1 = 2.
   ENDCASE.

   " Instantiate the completion API
   TRY.
       FINAL(api) = cl_aic_islm_compl_api_factory=>get( )->create_instance( intelligent_scenario ).

       DATA transaction_type_list TYPE string.
       SELECT * FROM ZTM364_I_Transaction_Type INTO TABLE @DATA(lt_transaction_types).
       LOOP AT lt_transaction_types REFERENCE INTO DATA(lr_transaction_type).
         transaction_type_list = |{ transaction_type_list }{ lr_transaction_type->Type } ({ lr_transaction_type->Description }),|.
       ENDLOOP.

       DATA lv_category_list TYPE string.
       SELECT * FROM ZTM364_I_Expense_Category INTO TABLE @DATA(lt_categories).
       LOOP AT lt_categories REFERENCE INTO DATA(lr_category).
         lv_category_list = |{ lv_category_list }{ lr_category->Category } ({ lr_category->Description }),|.
       ENDLOOP.

       prompt = |Analyze the attached receipt and extract the following information.{ cl_abap_char_utilities=>cr_lf }|
                 && |Do NOT wrap the response in markdown. Respond in valid JSON.{ cl_abap_char_utilities=>cr_lf }|
                 && |\{ { cl_abap_char_utilities=>cr_lf }|
                 && |"TransactionType" :"",{ cl_abap_char_utilities=>cr_lf }|
                 && |"Category" :"",{ cl_abap_char_utilities=>cr_lf }|
                 && |"ExpenseDescription" :"",{ cl_abap_char_utilities=>cr_lf }|
                 && |"Amount" :"",{ cl_abap_char_utilities=>cr_lf }|
                 && |"Currency" :""{ cl_abap_char_utilities=>cr_lf }|
                 && |"ReceiptDate" :""{ cl_abap_char_utilities=>cr_lf }|
                 && |\}{ cl_abap_char_utilities=>cr_lf }|
                 && |The following TransactionTypes exist in the system: { transaction_type_list }{ cl_abap_char_utilities=>cr_lf }|
                 && |The following Categories exist in the system: { lv_category_list }|.

       message_container = api->create_message_container( ).
       " Create a message container
       message_container->add_user_media_message( )->add_media( media_type )->set_media_data(
       cl_web_http_utility=>encode_x_base64( expense-UploadedReceipt ) )->add_text( prompt ).

       " Send the message to the LLM and get its response
       FINAL(answer) = api->execute_for_messages( message_container )->get_completion( ).

     CATCH cx_aic_completion_api
           cx_aic_api_factory
           cx_root INTO DATA(lx_previous).

       expense-TransactionType    = 'E'.
       expense-ExpenseDescription = |Error occurred: { lx_previous->get_text( ) }|.
       expense-Category           = 'E1'.
       update_line = CORRESPONDING #( expense ).
       APPEND update_line TO update.
       EXIT.

   ENDTRY.

   TRY.
       /ui2/cl_json=>deserialize( EXPORTING json        = answer
                                            pretty_name = /ui2/cl_json=>pretty_mode-none  " keep names as-is
                                  CHANGING  data        = expense ).
     CATCH cx_root INTO DATA(lx). " TODO: variable is assigned but never used (ABAP cleaner)

       expense-TransactionType    = 'E'.
       expense-ExpenseDescription = |Serialization error : { lx->get_text( ) }|.
       expense-Category           = 'E2'.
       update_line = CORRESPONDING #( expense ).
       APPEND update_line TO update.
       EXIT.
   ENDTRY.

   update_line = CORRESPONDING #( expense ).
   APPEND update_line TO update.

 ENDLOOP.

 MODIFY ENTITIES OF zr_trip912 IN LOCAL MODE
        ENTITY Expense
        UPDATE FIELDS ( ReceiptDate ExpenseDescription TransactionType Category Amount Currency )
        WITH update
        REPORTED DATA(update_reported).

 reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_trip912 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Trip
        RESULT result,
      setTripCategory FOR DETERMINE ON SAVE
        IMPORTING keys FOR Trip~setTripCategory,

      checkCompliance FOR MODIFY
        IMPORTING keys FOR ACTION Trip~checkCompliance RESULT result.
ENDCLASS.

CLASS lhc_zr_trip912 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD setTripCategory.

    DATA update TYPE TABLE FOR UPDATE zr_trip912\\Trip.
    DATA update_line TYPE STRUCTURE FOR UPDATE zr_trip912\\Trip .

    DATA recommendation_api TYPE REF TO ztm364_cl_islm_trip_type_912.

    recommendation_api = NEW #(  ).

    READ ENTITIES OF zr_trip912 IN LOCAL MODE
            ENTITY trip ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(trips).

    DELETE trips WHERE IslmScenario IS INITIAL.
    CHECK trips IS NOT INITIAL.

    LOOP AT trips INTO DATA(trip).

      recommendation_api->get_trip_type(
        EXPORTING
          i_title         = CONV #( trip-Title )
          i_details       = trip-Details
          i_islm_scenario = trip-IslmScenario
        IMPORTING
          e_response      = DATA(response)
          e_category      = DATA(category)
          e_enddate       = DATA(enddate)
          e_startdate     = DATA(startdate)
          e_country       = DATA(country)
          e_city          = DATA(city)
      ).

      update_line-%tky = trip-%tky.
      update_line-Type = category.
      update_line-LlmResponse = response.
      update_line-EndDate = enddate.
      update_line-StartDate = startdate.
      update_line-City = city.
      update_line-Country = country.

      APPEND update_line TO update.

    ENDLOOP.

    MODIFY ENTITIES OF zr_trip912 IN LOCAL MODE
      ENTITY Trip
      UPDATE FIELDS ( Type LlmResponse StartDate EndDate City Country )
      WITH  update
      REPORTED DATA(update_reported) .

    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.




**************************************************************************
* Instance-bound non-factory action:
* Check compliance of trip expenses
**************************************************************************
    METHOD checkCompliance.

      DATA islm_scenario  TYPE aic_islm_scenario_id=>type VALUE 'ZTM364_REUSE_GROUND'.

      DATA complianceAPI TYPE REF TO ztm364_cl_islm_trip_compl_912.
      complianceAPI = NEW #(  ).

      DATA update TYPE TABLE FOR UPDATE zr_trip912\\Trip.
      DATA update_line TYPE STRUCTURE FOR UPDATE zr_trip912\\Trip .

      TYPES : BEGIN OF t_expense,
                expensedescription TYPE c LENGTH 200,
                category           TYPE c LENGTH 2,
                transactiontype    TYPE c LENGTH 8,
                receiptdate        TYPE datn,
                amount             TYPE p LENGTH 8 DECIMALS 2,
                currency           TYPE waers,
              END OF t_expense.

      DATA expense_by_trip TYPE t_expense.
      DATA expenses_by_trip TYPE STANDARD TABLE OF t_expense.

      READ ENTITIES OF zr_trip912 IN LOCAL MODE
              ENTITY Trip ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(trips).

      READ ENTITIES OF zr_trip912 IN LOCAL MODE
            ENTITY Trip BY \_Expense ALL FIELDS WITH
            CORRESPONDING #( trips )
            LINK DATA(expense_links)
            RESULT DATA(expenses).

      LOOP AT trips INTO DATA(trip).

        LOOP AT expense_links INTO DATA(expense_link) USING KEY id WHERE
        source-%tky = trip-%tky.

          expense_by_trip = CORRESPONDING #( expenses[ KEY id  %tky = expense_link-target-%tky ] ).
          APPEND expense_by_trip TO expenses_by_trip.

        ENDLOOP.

        "serialize expenses to JSON
        DATA(expenses_as_json) = /ui2/cl_json=>serialize( data     = expenses_by_trip
                                                 compress    = abap_true
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

        complianceAPI->check_trip_compliance(
          EXPORTING
            i_trip_category     = trip-Type
            i_trip_details      = trip-Details
            i_trip_expenses     = expenses_as_json
            i_islm_scenario     = islm_scenario
           "i_show_grounding    = abap_false
          IMPORTING
            e_response          = update_line-LlmResponse
            e_compliance_status = update_line-status
        ).

        update_line-%tky = trip-%tky.

        APPEND update_line TO update.

      ENDLOOP.

      MODIFY ENTITIES OF zr_trip912 IN LOCAL MODE
        ENTITY Trip
        UPDATE FIELDS (  LlmResponse status )
        WITH  update
        REPORTED DATA(update_reported) .

      " read changed data for action result
      READ ENTITIES OF zr_trip912 IN LOCAL MODE
          ENTITY Trip
          ALL FIELDS WITH
          CORRESPONDING #( trips )
          RESULT DATA(trips_with_compliance_check).

      "Set the changing parameter
      reported = CORRESPONDING #( DEEP update_reported ).

      " set action result
      result = VALUE #( FOR trip_compl IN trips_with_compliance_check ( %tky   = trip_compl-%tky
                                                                %param = trip_compl ) ).



    ENDMETHOD.


ENDCLASS.
