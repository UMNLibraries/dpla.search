# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include HubSearch::SolrHelper::Authorization

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :qt => 'search_hub',
      :fl => '*',
      :rows => 100
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_ssi'
    config.index.display_type_field = 'sourceResource_type_ssi'
    config.index.thumbnail_field = :object_ssi

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'ham_fsi', :label => 'Ham Ranking', :sort => 'index', :limit => 50
    config.add_facet_field 'spam_fsi', :label => 'Spam Ranking', :sort => 'index', :limit => 50
    facets = {
      "tags_ssim" => "Import Job Tags",
      "import_job_name_ssi" => "Import Job Name",
      "import_job_id_isi" => "Import Job ID",
      "title_ssi" => "Title",
      "published_bsi" => "Is Published",
      "ingested_at_dti" => "Injested At",
      "status_ssi" => "Status",
      "intermediateProvider_ssi" => "Provider",
      "language_ssi" => "Language",
      "subject_ssim" => "Subject",
      "creator_ssim" => "Creator",
      "object_ssi" => "Object",
      "dataProvider_ssi" => "Data Provider",
      "isShownAt_ssi" => "Is Shown At",
      "provider_name_ssi" => "Provider Name",
      "sourceResource_collection_title_ssi" => "Collection Title",
      "sourceResource_collection_id_ssi" => "Collection ID",
      "sourceResource_contributor_ssi" => "Contributor",
      "sourceResource_creator_ssi" => "Creator",
      "sourceResource_date_begin_ssi" => "Date Begin",
      "sourceResource_date_displaydate_ssi" => "Display Date",
      "sourceResource_extent_ssi" => "Extent",
      "sourceResource_format_ssi" => "Format",
      "sourceResource_identifier_ssi" => "Identifier",
      "sourceResource_language_iso639_ssi" => "Language ISO",
      "sourceResource_publisher_ssi" => "Publisher",
      "sourceResource_location_facet_ssim" => "Location",
      "sourceResource_spatial_city_ssi" => "City",
      "sourceResource_spatial_county_ssi" => "County",
      "sourceResource_spatial_name_ssi" => "Place Name",
      "sourceResource_spatial_region_ssi" => "Region",
      "sourceResource_spatial_state_ssi" => "Stage",
      "sourceResource_physicalMedium_ssi" => "Physical Medium",
      "sourceResource_type_ssi" => "Type",
      "sourceResource_rights_ssi" => "Rights"
    }

  facets.each do |field_name, label|
    config.add_facet_field field_name, :label => label, :limit => 20
  end

  config.add_index_field 'ham_fsi', :label => 'Ham Ranking'
  config.add_index_field 'spam_fsi', :label => 'Spam Ranking'

  facets.each do |field_name, label|
    config.add_index_field field_name, :label => label
  end

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 

    config.add_search_field 'all_fields', :label => 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      # field.solr_parameters = { :'spellcheck.dictionary' => 'title_ssi' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('creator') do |field|
      # field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :qf => '$creator_qf',
        :pf => '$creator_pf'
      }
    end

    config.add_search_field('subject') do |field|
      # field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_ssort asc', :label => 'relevance'
    config.add_sort_field 'creator_ssort asc, title_ssort asc', :label => 'creator'
    config.add_sort_field 'title_ssort asc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end
