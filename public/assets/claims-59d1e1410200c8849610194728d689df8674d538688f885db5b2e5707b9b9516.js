(function() {
  jQuery(function() {
    $('#claim_medium_name').autocomplete({
      source: $('#claim_medium_name').data('autocomplete-source')
    });
  });

  jQuery(function() {
    $('#claim_src_name').autocomplete({
      source: $('#claim_src_name').data('autocomplete-source')
    });
  });

}).call(this);
