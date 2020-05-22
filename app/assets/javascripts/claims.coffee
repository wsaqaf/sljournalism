# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#jQuery ->
#  $('#claim_claim_source_name').autocomplete source: new_data=$('#claim_claim_source_name').data('data_autocomplete_source')
#  return

jQuery ->
  $('#claim_medium_name').autocomplete source: $('#claim_medium_name').data('autocomplete-source')
  return
jQuery ->
  $('#claim_src_name').autocomplete source: $('#claim_src_name').data('autocomplete-source')
  return
