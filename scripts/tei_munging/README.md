
Steps to redoing the LC files are as follows: 

1: Brian turnes files into p5, Laura does a bit of light header work
2: Karin renames the files, fitting into these broad categories: 
  - lc.about.
  - lc.img.
  - lc.jrn.
  - lc.mult.
  - lc.sup.
3: run all files through 00a_set_xmlid_to_filename
4: run journals only through 01_journals_insert_geo.xsl and 02_journals_add_xml_id_author.xsl
5: run all files throguh 03_add_empty_category_tags.xsl and 04_add_category_and_subcategory.xsl