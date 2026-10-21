CLASS ztm364_cl_fill_tables DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ztm364_cl_fill_tables IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA transaction_types TYPE TABLE OF ztm364_tran_type.
    DATA transaction_type TYPE ztm364_tran_type.

    DATA trip_types TYPE TABLE OF ztm364_trip_type.
    DATA trip_type TYPE ztm364_trip_type.

    DATA expense_categories TYPE TABLE OF ztm364_expn_cat.
    DATA expense_category TYPE ztm364_expn_cat.

    DATA compliance_statuses TYPE TABLE OF ztm364_compl_st.
    DATA compliance_status TYPE ztm364_compl_st.

    DELETE FROM ztm364_compl_st.
    COMMIT WORK.

    DELETE FROM ztm364_tran_type.
    COMMIT WORK.

    DELETE FROM ztm364_trip_type.
    COMMIT WORK.

    DELETE FROM ztm364_expn_cat.
    COMMIT WORK.

    TRY.

        transaction_type-client = sy-mandt.
        transaction_type-local_created_by  = sy-uname.
        transaction_type-local_created_at  = cl_abap_context_info=>get_system_time( ).
        transaction_type-local_last_changed_by = sy-uname.
        transaction_type-local_last_changed_at = cl_abap_context_info=>get_system_time( ).
        transaction_type-last_changed_at   = cl_abap_context_info=>get_system_time( ).

        transaction_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        transaction_type-type              = 'CC'.
        transaction_type-description       = 'Credit card'.
        APPEND transaction_type TO transaction_types.

        transaction_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        transaction_type-type              = 'CASH'.
        transaction_type-description       = 'Cash'.
        APPEND transaction_type TO transaction_types.

        transaction_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        transaction_type-type              = 'WIRE'.
        transaction_type-description       = 'Cash'.
        APPEND transaction_type TO transaction_types.

        "fill trip types

        trip_type-client = sy-mandt.
        trip_type-local_created_by  = sy-uname.
        trip_type-local_created_at  = cl_abap_context_info=>get_system_time( ).
        trip_type-local_last_changed_by = sy-uname.
        trip_type-local_last_changed_at = cl_abap_context_info=>get_system_time( ).
        trip_type-last_changed_at   = cl_abap_context_info=>get_system_time( ).

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'CM'.
        trip_type-description       = 'Client meeting'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'ST'.
        trip_type-description       = 'Sales trip'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'CC'.
        trip_type-description       = 'Conference'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'IM'.
        trip_type-description       = 'Internal meeting'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'TO'.
        trip_type-description       = 'Team offsite'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'SV'.
        trip_type-description       = 'Site visit'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'FW'.
        trip_type-description       = 'Field work'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'ED'.
        trip_type-description       = 'Eduction'.
        APPEND trip_type TO trip_types.

        trip_type-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        trip_type-type              = 'TR'.
        trip_type-description       = 'Training'.
        APPEND trip_type TO trip_types.

        expense_category-client = sy-mandt.
        expense_category-local_created_by  = sy-uname.
        expense_category-local_created_at  = cl_abap_context_info=>get_system_time( ).
        expense_category-local_last_changed_by = sy-uname.
        expense_category-local_last_changed_at = cl_abap_context_info=>get_system_time( ).
        expense_category-last_changed_at   = cl_abap_context_info=>get_system_time( ).

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'FL'.
        expense_category-description       = 'Flight'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'TT'.
        expense_category-description       = 'Train ticket'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'CR'.
        expense_category-description       = 'Car rental'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'FU'.
        expense_category-description       = 'Fuel & Gas'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'TX'.
        expense_category-description       = 'Taxi & Rideshare'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'PB'.
        expense_category-description       = 'Public transit'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'PT'.
        expense_category-description       = 'Parking & tolls'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'HT'.
        expense_category-description       = 'Hotel'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'WF'.
        expense_category-description       = 'Internet & WiFi'.
        APPEND expense_category TO expense_categories.

        expense_category-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        expense_category-category          = 'CE'.
        expense_category-description       = 'Client Entertainment'.
        APPEND expense_category TO expense_categories.

        compliance_status-client = sy-mandt.
        compliance_status-local_created_by  = sy-uname.
        compliance_status-local_created_at  = cl_abap_context_info=>get_system_time( ).
        compliance_status-local_last_changed_by = sy-uname.
        compliance_status-local_last_changed_at = cl_abap_context_info=>get_system_time( ).
        compliance_status-last_changed_at   = cl_abap_context_info=>get_system_time( ).

        "compliant (C), non-compliant (N), manager-approval-needed (M)

        compliance_status-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        compliance_status-compliance_status         = 'C'.
        compliance_status-description       = 'Compliant'.
        APPEND compliance_status TO compliance_statuses.

        compliance_status-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        compliance_status-compliance_status         = 'N'.
        compliance_status-description       = 'Non-compliant'.
        APPEND compliance_status TO compliance_statuses.

        compliance_status-uuid              = cl_system_uuid=>create_uuid_x16_static( ).
        compliance_status-compliance_status         = 'M'.
        compliance_status-description       = 'manager-approval-needed'.
        APPEND compliance_status TO compliance_statuses.

        " Add more entries as needed...

        INSERT ztm364_compl_st FROM TABLE @compliance_statuses.
        INSERT ztm364_tran_type FROM TABLE @transaction_types.
        INSERT ztm364_trip_type FROM TABLE @trip_types.
        INSERT ztm364_expn_cat FROM TABLE @expense_categories.

        COMMIT WORK.

        SELECT COUNT( * ) FROM ztm364_compl_st INTO @DATA(num_of_compliance_statuses).
        SELECT COUNT( * ) FROM ztm364_tran_type INTO @DATA(num_of_transaction_types).
        SELECT COUNT( * ) FROM ztm364_trip_type INTO @DATA(num_of_trip_types).
        SELECT COUNT( * ) FROM ztm364_expn_cat INTO @DATA(num_of_expense_categories).

        out->write( |{ num_of_compliance_statuses } num_of_compliance_statuses| ).
        out->write( |{ num_of_transaction_types } num_of_transaction_types| ).
        out->write( |{ num_of_trip_types } num_of_trip_types| ).
        out->write( |{ num_of_expense_categories } num_of_expense_categories| ).

      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
