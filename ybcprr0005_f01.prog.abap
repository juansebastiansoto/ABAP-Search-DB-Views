*&---------------------------------------------------------------------*
*& Form ALV_INPUT_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM alv_input_layout_left  CHANGING pw_layo TYPE lvc_s_layo.

  pw_layo-zebra = pw_layo-cwidth_opt = pw_layo-no_rowmark = pw_layo-no_toolbar = abap_true.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ALV_INPUT_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM alv_input_fcat_left  CHANGING pt_fcat TYPE lvc_t_fcat.

  DATA: ol_alv_magic TYPE REF TO zcl_alv.

  DATA: wl_structure TYPE ty_table_definition,
        wl_fcat      TYPE lvc_s_fcat.

  CREATE OBJECT ol_alv_magic.

  CALL METHOD ol_alv_magic->fill_catalog_merge
    EXPORTING
      structure = wl_structure
      texts     = abap_true
      convexit  = abap_true
      tabname   = 'T_TABLE_DEFINITION'
    IMPORTING
      fieldcat  = pt_fcat.

  DELETE pt_fcat WHERE fieldname NE 'CHECK'
                   AND fieldname NE 'TABNAME'
                   AND fieldname NE 'FIELDNAME'
                   AND fieldname NE 'KEYFLAG'
                   AND fieldname NE 'CHECKTABLE'
                   AND fieldname NE 'ROLLNAME'.

  wl_fcat-edit = wl_fcat-checkbox = abap_true.
  MODIFY pt_fcat FROM wl_fcat TRANSPORTING edit checkbox WHERE fieldname EQ 'CHECK'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ALV_INPUT_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM alv_input_layout_right CHANGING pw_layo TYPE lvc_s_layo.

  pw_layo-zebra = pw_layo-cwidth_opt = pw_layo-no_rowmark = pw_layo-no_toolbar = abap_true.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ALV_INPUT_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM alv_input_fcat_right  CHANGING pt_fcat TYPE lvc_t_fcat.

  DATA: ol_alv_magic TYPE REF TO zcl_alv.

  DATA: wl_structure TYPE ty_design.

  CREATE OBJECT ol_alv_magic.

  CALL METHOD ol_alv_magic->fill_catalog_merge
    EXPORTING
      structure = wl_structure
      texts     = abap_true
      convexit  = abap_true
      tabname   = 'T_DESIGN'
    IMPORTING
      fieldcat  = pt_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_TABLE_DEFINITION
*&---------------------------------------------------------------------*
*& Read P_TABLE table definition
*&---------------------------------------------------------------------*
*&      <-- TL_TABLE_DEFINITION
*&---------------------------------------------------------------------*
FORM get_table_definition.

  DATA: tl_table_definition TYPE dd03ptab.

  DATA: wl_table_definition_db  TYPE LINE OF dd03ptab,
        wl_table_definition_alv TYPE ty_table_definition.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = p_table
      langu         = sy-langu
    TABLES
      dd03p_tab     = tl_table_definition
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR t_table_definition.

  LOOP AT tl_table_definition INTO wl_table_definition_db.

    MOVE-CORRESPONDING wl_table_definition_db TO wl_table_definition_alv.
    APPEND wl_table_definition_alv TO t_table_definition.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_SCREEN_ELEMENTS
*&---------------------------------------------------------------------*
*& Create the container, splitters and ALV objects
*&---------------------------------------------------------------------*
FORM create_screen_elements.

  DATA: tl_fcat_l TYPE lvc_t_fcat,
        tl_fcat_r TYPE lvc_t_fcat.

  DATA: wl_layo_l TYPE lvc_s_layo,
        wl_layo_r TYPE lvc_s_layo.

  IF o_dock IS NOT INITIAL.
    RETURN.
  ENDIF.

**********************************************************************
* 1.- Create main docker to get access at the select screen
**********************************************************************

  CREATE OBJECT o_dock
    EXPORTING
      repid = sy-cprog
      dynnr = sy-dynnr
      ratio = 90
      side  = cl_gui_docking_container=>dock_at_bottom
      name  = 'DOCK_CONT'.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  o_cont ?= o_dock.

**********************************************************************
* 2.- Split the docker in two columns
**********************************************************************

  CREATE OBJECT o_split
    EXPORTING
      parent            = o_cont
      rows              = 1
      columns           = 2
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  o_split->set_border( abap_true ).

  o_contl = o_split->get_container( EXPORTING row = 1 column = 1 ).
  o_contr = o_split->get_container( EXPORTING row = 1 column = 2 ).

**********************************************************************
* 3.- Create the left ALV for the P_TABLE definition
**********************************************************************
  CREATE OBJECT o_alv_l
    EXPORTING
      i_parent          = o_contl
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  PERFORM alv_input_layout_left CHANGING wl_layo_l.
  PERFORM alv_input_fcat_left   CHANGING tl_fcat_l.

  CALL METHOD o_alv_l->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD o_alv_l->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layo_l
    CHANGING
      it_outtab                     = t_table_definition
      it_fieldcatalog               = tl_fcat_l
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

**********************************************************************
* 4.- Create the right ALV for the selected fields in the left ALV
**********************************************************************

  CREATE OBJECT o_alv_r
    EXPORTING
      i_parent          = o_contr
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  PERFORM alv_input_layout_right CHANGING wl_layo_r.
  PERFORM alv_input_fcat_right   CHANGING tl_fcat_r.

  CALL METHOD o_alv_r->set_table_for_first_display
    EXPORTING
      is_layout                     = wl_layo_r
    CHANGING
      it_outtab                     = t_design
      it_fieldcatalog               = tl_fcat_r
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPDATE_ALV_LEFT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_alv_left .

  PERFORM get_table_definition.

  CALL METHOD o_alv_l->refresh_table_display
    EXCEPTIONS
      finished = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPDATE_ALV_RIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_alv_right.

  CALL METHOD o_alv_r->refresh_table_display
    EXCEPTIONS
      finished = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_SELECTION_BUTTONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_selection_buttons .

  DATA: wl_functxt TYPE smp_dyntxt.

* ZBCCAT Config button
  wl_functxt-icon_id   = icon_insert_multiple_lines.
  wl_functxt-quickinfo = TEXT-q01.

  sscrfields-functxt_01 = wl_functxt.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_SELECTED_FIELDS
*&---------------------------------------------------------------------*
*& Set selected fields from Left ALV into Right ALV
*&---------------------------------------------------------------------*
FORM set_selected_fields.

  DATA: wl_table_definition TYPE ty_table_definition,
        wl_design           TYPE ty_design.

  LOOP AT t_table_definition INTO wl_table_definition WHERE check EQ abap_true.

    wl_design-tabname   = wl_table_definition-tabname.
    wl_design-fieldname = wl_table_definition-fieldname.
    APPEND wl_design TO t_design.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SEARCH_VIEWS
*&---------------------------------------------------------------------*
FORM search_views.

  TYPES: BEGIN OF tyl_dd27s,
           viewname  TYPE dd27s-viewname,
           tabname   TYPE dd27s-tabname,
           fieldname TYPE dd27s-fieldname,
         END OF tyl_dd27s.

  DATA: tl_dd27s     TYPE STANDARD TABLE OF tyl_dd27s..

  DATA: wl_dd27s  TYPE tyl_dd27s,
        wl_design TYPE ty_design.

  DATA: vl_viewname   TYPE dd27s-viewname,
        vl_view_count TYPE i,
        vl_foot       TYPE string,
        fl_match      TYPE boolean.

  IF t_design IS INITIAL.
    RETURN.
  ENDIF.

  SELECT viewname tabname fieldname
  FROM dd27s
  INTO TABLE tl_dd27s
  FOR ALL ENTRIES IN t_design
  WHERE tabname   EQ t_design-tabname
    AND fieldname EQ t_design-fieldname.

  SORT tl_dd27s.

  LOOP AT tl_dd27s INTO wl_dd27s.

    vl_viewname = wl_dd27s-viewname.

    AT NEW viewname.

      fl_match = abap_true.

      LOOP AT t_design INTO wl_design.

        READ TABLE tl_dd27s
        TRANSPORTING NO FIELDS
        WITH KEY viewname  = vl_viewname
                 tabname   = wl_design-tabname
                 fieldname = wl_design-fieldname.

        IF sy-subrc NE 0.
          fl_match = abap_false.
        ENDIF.

      ENDLOOP.

      IF fl_match EQ abap_true.
        ADD 1 TO vl_view_count.
        PERFORM viewname_output USING vl_viewname.
      ENDIF.

    ENDAT.

  ENDLOOP.

  MESSAGE s029(adw) WITH vl_view_count INTO vl_foot.
* There are &1 matches

  SKIP.

  FORMAT COLOR 4 INTENSIFIED ON.

  WRITE:/ vl_foot.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form VIEWNAME_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM viewname_output  USING pv_viewname TYPE dd27s-viewname.

  DATA: wl_dd25t  TYPE dd25t.

  SELECT SINGLE *
  FROM dd25t
  INTO wl_dd25t
  WHERE ddlanguage EQ sy-langu
    AND viewname   EQ pv_viewname
    AND as4local   EQ 'A'
    AND as4vers    EQ '0000'.

  IF sy-subrc NE 0.

    SELECT SINGLE *
    FROM dd25t
    INTO wl_dd25t
    WHERE viewname   EQ pv_viewname
      AND as4local   EQ 'A'
      AND as4vers    EQ '0000'.

  ENDIF.

  WRITE:/ wl_dd25t-viewname, wl_dd25t-ddtext.

ENDFORM.
