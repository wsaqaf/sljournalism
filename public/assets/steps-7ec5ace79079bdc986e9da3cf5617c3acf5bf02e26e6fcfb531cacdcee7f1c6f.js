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

  $(document).ready(function() {
    $('.collapse').on('shown.bs.collapse', function() {
      $(this).parent().find('.glyphicon-plus').removeClass('glyphicon-plus').addClass('glyphicon-minus');
    }).on('hidden.bs.collapse', function() {
      $(this).parent().find('.glyphicon-minus').removeClass('glyphicon-minus').addClass('glyphicon-plus');
    });
  });

}).call(this);
