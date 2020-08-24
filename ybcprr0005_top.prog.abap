
TABLES sscrfields.

TYPES: BEGIN OF ty_design,
         tabname   TYPE dd03l-tabname,
         fieldname TYPE dd03l-fieldname,
       END OF ty_design,
       BEGIN OF ty_table_definition,
         check TYPE check_box.
    INCLUDE TYPE dd03p.
TYPES: END OF ty_table_definition.



DATA: o_dock  TYPE REF TO cl_gui_docking_container,
      o_cont  TYPE REF TO cl_gui_container,
      o_contl TYPE REF TO cl_gui_container,
      o_contr TYPE REF TO cl_gui_container,
      o_split TYPE REF TO cl_gui_splitter_container,
      o_alv_l TYPE REF TO cl_gui_alv_grid,
      o_alv_r TYPE REF TO cl_gui_alv_grid.

DATA: t_design           TYPE STANDARD TABLE OF ty_design,
      t_table_definition TYPE STANDARD TABLE OF ty_table_definition.
