# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('#claim_medium_name').autocomplete source: $('#claim_medium_name').data('autocomplete-source')
#  $('#claim_medium_name').autocomplete source: $('#claim_medium_name').data('autocomplete-source')
  return
jQuery ->
  $('#claim_src_name').autocomplete source: $('#claim_src_name').data('autocomplete-source')
  return

$(document).ready ->
  $('.collapse').on('shown.bs.collapse', ->
    $(this).parent().find('.glyphicon-plus').removeClass('glyphicon-plus').addClass 'glyphicon-minus'
    return
  ).on 'hidden.bs.collapse', ->
    $(this).parent().find('.glyphicon-minus').removeClass('glyphicon-minus').addClass 'glyphicon-plus'
    return
  return
