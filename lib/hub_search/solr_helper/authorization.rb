module HubSearch::SolrHelper::Authorization

 def self.included base
   base.solr_search_params_logic += [:show_only_published_records]
 end

  # solr_search_params_logic methods take two arguments
  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  # @param [Hash] user_parameters a hash of user-supplied parameters (often via `params`)
  def show_only_published_records solr_parameters, user_parameters
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1
    solr_parameters = limit_by_user(solr_parameters)
  end

  private

  def limit_by_user(solr_parameters)
    if !current_user
      solr_parameters['q.alt'] = 'published_bsi:true'
    elsif current_user.has_role?('admin')
      solr_parameters
    elsif !current_user.authorized_import_job_ids.nil?
      authorized_jobs = current_user.authorized_import_job_ids.split(',').join('OR import_job_id_isi:')
      solr_parameters['q.alt'] = "import_job_id_isi:#{authorized_jobs} OR published_bsi:true"
    else
      solr_parameters['q.alt'] = 'published_bsi:true'
    end
    solr_parameters
  end
end