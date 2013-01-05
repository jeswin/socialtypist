// Generated by CoffeeScript 1.3.1
(function() {
  var HistoryPane,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HistoryPane = (function() {

    HistoryPane.name = 'HistoryPane';

    function HistoryPane(story, editor, view) {
      this.story = story;
      this.editor = editor;
      this.view = view;
      this.fetchHistory = __bind(this.fetchHistory, this);

      this.fetchHistory();
    }

    HistoryPane.prototype.fetchHistory = function() {
      var _this = this;
      return $.get("/stories/" + story._id + "/history", function(response) {
        return console.log(JSON.stringify(response));
      });
    };

    return HistoryPane;

  })();

  this.SocialTypist.StoryEditView.HistoryPane = HistoryPane;

}).call(this);
