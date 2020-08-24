REPORT ybcprr0005.

INCLUDE ybcprr0005_top.
INCLUDE ybcprr0005_sel.
INCLUDE ybcprr0005_f01.

INITIALIZATION.

  PERFORM add_selection_buttons.
  PERFORM create_screen_elements.

AT SELECTION-SCREEN ON p_table.

  IF sy-ucomm NE 'FC01'.
    PERFORM update_alv_left.
  ENDIF.

AT SELECTION-SCREEN.

  IF sy-ucomm EQ 'FC01'.
    PERFORM set_selected_fields.
    PERFORM update_alv_right.
  ENDIF.

START-OF-SELECTION.

  PERFORM search_views.
