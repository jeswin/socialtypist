// Generated by CoffeeScript 1.2.1-pre
(function() {
  var StoryEditView,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  StoryEditView = (function() {

    StoryEditView.name = 'StoryEditView';

    function StoryEditView(story, container) {
      this.story = story;
      this.addSection = __bind(this.addSection, this);

      this.deletePart = __bind(this.deletePart, this);

      this.cancelPartEdit = __bind(this.cancelPartEdit, this);

      this.savePart = __bind(this.savePart, this);

      this.editVideoPart = __bind(this.editVideoPart, this);

      this.editImagePart = __bind(this.editImagePart, this);

      this.editTextPart = __bind(this.editTextPart, this);

      this.editHeadingPart = __bind(this.editHeadingPart, this);

      this.renderVideoPart = __bind(this.renderVideoPart, this);

      this.renderImagePart = __bind(this.renderImagePart, this);

      this.renderTextPart = __bind(this.renderTextPart, this);

      this.renderHeadingPart = __bind(this.renderHeadingPart, this);

      this.bindPartEditClick = __bind(this.bindPartEditClick, this);

      this.bindTitleEditClick = __bind(this.bindTitleEditClick, this);

      this.renderPart = __bind(this.renderPart, this);

      this.renderParts = __bind(this.renderParts, this);

      this.cancelTitleEdit = __bind(this.cancelTitleEdit, this);

      this.saveTitle = __bind(this.saveTitle, this);

      this.editTitle = __bind(this.editTitle, this);

      this.renderTitle = __bind(this.renderTitle, this);

      this.render = __bind(this.render, this);

      this.initialize = __bind(this.initialize, this);

      this.container = $(container);
      this.initialize();
    }

    StoryEditView.prototype.initialize = function() {
      return this.showdown = new Showdown.converter();
    };

    StoryEditView.prototype.render = function() {
      this.renderTitle();
      return this.renderParts();
    };

    StoryEditView.prototype.renderTitle = function() {
      var title;
      this.container.append("<div class=\"editable title\"><h1 class=\"title\">" + story.title + "</h1></div>");
      title = this.container.find('.editable.title');
      title.data('title', story.title);
      return this.bindTitleEditClick(title);
    };

    StoryEditView.prototype.editTitle = function() {
      var editable, val,
        _this = this;
      editable = $('#story-editor .editable.title');
      editable.addClass('selected');
      val = editable.data('title');
      editable.html("            <form class=\"title-editor\">                <input type=\"text\" class=\"span6\" /><br />                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>                <hr />                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>            </form>");
      editable.find('.title-editor input').val(val);
      editable.find('a.save').click(function() {
        _this.saveTitle();
        return false;
      });
      editable.find('a.cancel').click(function() {
        _this.cancelTitleEdit();
        return false;
      });
      return editable.find('.insert').click(function() {
        _this.addSection('start');
        return false;
      });
    };

    StoryEditView.prototype.saveTitle = function() {
      var editable;
      editable = $('#story-editor .editable.title');
      this.bindTitleEditClick(editable);
      editable.removeClass('selected');
      return editable.html("<h1 class=\"title\">" + ($('.title-editor input').val()) + "</h1>");
    };

    StoryEditView.prototype.cancelTitleEdit = function() {
      var editable;
      editable = $('#story-editor .editable.title');
      this.bindTitleEditClick(editable);
      editable.removeClass('selected');
      return editable.html("<h1 class=\"title\">" + (editable.data('title')) + "</h1>");
    };

    StoryEditView.prototype.renderParts = function() {
      var part, previous, _i, _len, _ref, _results,
        _this = this;
      this.container.append('<ul id="part-editor" class="story"></ul>');
      this.container.append('<p class="add-section"><span class="plus">+</span><a class="small action" href="#">add new section</a></p>');
      this.container.find('.add-section a').click(function() {
        _this.addSection('end');
        return false;
      });
      this.editor = this.container.find('#part-editor').first();
      if (this.story._objects.parts.length) {
        _ref = this.story._objects.parts;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          part = _ref[_i];
          _results.push(previous = this.renderPart(part, previous));
        }
        return _results;
      }
    };

    StoryEditView.prototype.renderPart = function(part, previousElement) {
      var partElem;
      partElem = this.editor.find("#storypart_" + part._id);
      if (!partElem.length) {
        if (!previousElement) {
          this.editor.prepends("<li class=\"content editable\" id=\"storypart_" + part._id + "\"><br /></li>");
        } else {
          $("<li class=\"content editable\" id=\"storypart_" + part._id + "\"></li>").insertAfter(previousElement);
        }
        partElem = this.editor.find("#storypart_" + part._id);
      }
      partElem.data('part', part);
      switch (part.type) {
        case 'HEADING':
          this.renderHeadingPart(partElem);
          break;
        case 'TEXT':
          this.renderTextPart(partElem);
          break;
        case 'IMAGE':
          this.renderImagePart(partElem);
          break;
        case 'VIDEO':
          this.renderVideoPart(partElem);
      }
      this.bindPartEditClick(partElem);
      return partElem;
    };

    StoryEditView.prototype.bindTitleEditClick = function(title) {
      var _this = this;
      return title.click(function() {
        title.unbind('click');
        return _this.editTitle();
      });
    };

    StoryEditView.prototype.bindPartEditClick = function(partElem) {
      var _this = this;
      return partElem.click(function() {
        partElem.unbind('click');
        return _this.editPart(partElem);
      });
    };

    StoryEditView.prototype.renderHeadingPart = function(partElem) {
      var headingSize, part;
      part = partElem.data('part');
      headingSize = (function() {
        switch (part.size) {
          case 'H1':
            return '#';
          case 'H2':
            return '##';
          case 'H3':
            return '###';
          case 'H4':
            return '####';
          case 'H5':
            return '#####';
          case 'H6':
            return '######';
        }
      })();
      return partElem.html(this.showdown.makeHtml(headingSize + part.value));
    };

    StoryEditView.prototype.renderTextPart = function(partElem) {
      var part;
      part = partElem.data('part');
      return partElem.html(this.showdown.makeHtml(part.value));
    };

    StoryEditView.prototype.renderImagePart = function(partElem) {
      var alt, part, _ref;
      part = partElem.data('part');
      alt = (_ref = part.alt) != null ? _ref : '';
      return partElem.html("<img src=\"" + part.value + "\" alt=\"" + alt + "\" />");
    };

    StoryEditView.prototype.renderVideoPart = function(partElem) {
      var part;
      part = partElem.data('part');
      return partElem.html(this.showdown.makeHtml(part.value));
    };

    StoryEditView.prototype.editPart = function(elem) {
      var part,
        _this = this;
      part = elem.data('part');
      elem.addClass('selected');
      switch (part.type) {
        case 'HEADING':
          this.editHeadingPart(elem);
          break;
        case 'TEXT':
          this.editTextPart(elem);
          break;
        case 'IMAGE':
          this.editImagePart(elem);
          break;
        case 'VIDEO':
          this.editVideoPart(elem);
      }
      elem.find('.save').click(function() {
        _this.savePart(elem);
        return false;
      });
      elem.find('.cancel').click(function() {
        _this.cancelPartEdit(elem);
        return false;
      });
      elem.find('.delete').click(function() {
        _this.deletePart(elem);
        return false;
      });
      elem.find('.insert').click(function() {
        _this.addSection(elem);
        return false;
      });
      return elem.find('textarea').focus();
    };

    StoryEditView.prototype.editHeadingPart = function(elem) {
      var part;
      part = elem.data('part');
      return elem.html("            <form>                <input type=\"text\" class=\"span6\" value=\"" + part.value + "\" />                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>                <hr />                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>            </form>");
    };

    StoryEditView.prototype.editTextPart = function(elem) {
      var part, rows;
      part = elem.data('part');
      if (elem.height() > 480) {
        rows = 28;
      } else if (elem.height() > 240) {
        rows = 16;
      } else {
        rows = 8;
      }
      return elem.html("            <form>                <textarea rows=\"" + rows + "\">" + part.value + "</textarea>                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>                <hr />                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>            </form>");
    };

    StoryEditView.prototype.editImagePart = function(elem) {
      var part;
      part = elem.data('part');
      return elem.html("            <form>                <input type=\"text\" class=\"span6\" value=\"" + part.value + "\" />                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>                <hr />                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>            </form>");
    };

    StoryEditView.prototype.editVideoPart = function(elem) {
      var part;
      part = elem.data('part');
      return elem.html("            <form>                <input type=\"text\" class=\"span6\" value=\"" + part.value + "\" />                <p class=\"left\"><a class=\"save btn small\" href=\"#\">Save section</a> <a class=\"cancel small action\" href=\"#\">cancel</a></p>                <hr />                <p class=\"add-section\"><span class=\"plus\">+</span><a class=\"small action insert\" href=\"#\">insert section below</a></p>            </form>");
    };

    StoryEditView.prototype.savePart = function(elem) {
      var part;
      this.bindPartEditClick(elem);
      part = elem.data('part');
      elem.removeClass('selected');
      part.value = elem.find('textarea').val();
      return elem.html(this.showdown.makeHtml(elem.find('textarea').val()));
    };

    StoryEditView.prototype.cancelPartEdit = function(elem) {
      var part;
      this.bindPartEditClick(elem);
      part = elem.data('part');
      elem.removeClass('selected');
      return elem.html(this.showdown.makeHtml(part.value));
    };

    StoryEditView.prototype.deletePart = function(elem) {
      var part;
      this.bindPartEditClick(elem);
      part = elem.data('part');
      return elem.remove();
    };

    StoryEditView.prototype.addSection = function(previous) {
      var added, content, elem,
        _this = this;
      elem = (function() {
        switch (previous) {
          case 'start':
            return $('#part-editor').children().first();
          case 'end':
            return $('#part-editor').children().last();
          default:
            return previous.next();
        }
      })();
      if (elem.hasClass('unsaved')) return;
      content = "            <li class=\"unsaved form\">                <select class=\"part-type\">                    <option value=\"HEADING\">Heading</option>                    <option value=\"TEXT\" selected=\"selected\">Text</option>                    <option value=\"IMAGE\">Image</option>                    <option value=\"VIDEO\">Video</option>                </select>                <p>                    <a href=\"#\" class=\"btn add\">Add</a>                    <a href=\"#\" class=\"small action cancel\">cancel</a>                </p>            </li>        ";
      if (previous === 'start') {
        $('#part-editor').prepend(content);
        added = $('#part-editor').children().first();
      } else if (previous === 'end') {
        $('#part-editor').append(content);
        added = $('#part-editor').children().last();
      } else {
        $(content).insertAfter(previous);
        added = previous.next();
      }
      added.find('.add').click(function() {
        var part;
        part = {
          type: added.find('.part-type').val()
        };
        return _this.renderPart(part, added.previous());
      });
      return added.find('.cancel').click(function() {
        added.remove();
        return false;
      });
    };

    return StoryEditView;

  })();

  this.SocialTypist.StoryEditView = StoryEditView;

}).call(this);