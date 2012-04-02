(function() {
  var dumpError, extend, isComposite, mergeLinkedObjects, mergeObjects, root, uniqueId;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  extend = function(target, source) {
    var key, val, _results;
    _results = [];
    for (key in source) {
      val = source[key];
      _results.push(target[key] = val);
    }
    return _results;
  };

  isComposite = function(dataType) {
    return dataType !== 'Text' && dataType !== 'Number' && dataType !== 'Boolean' && dataType !== 'DateTime' && dataType !== 'Selection' && dataType !== 'HTML' && dataType !== 'File';
  };

  mergeObjects = function(target, source) {
    var key, mergeArrays, val;
    mergeArrays = function(targetArr, sourceArr) {
      var item, matches, newArr, x, _i, _j, _k, _len, _len2, _len3, _results;
      newArr = [];
      for (_i = 0, _len = sourceArr.length; _i < _len; _i++) {
        item = sourceArr[_i];
        matches = (function() {
          var _j, _len2, _results;
          _results = [];
          for (_j = 0, _len2 = targetArr.length; _j < _len2; _j++) {
            x = targetArr[_j];
            if (x.name === item.name) _results.push(x);
          }
          return _results;
        })();
        if (matches.length > 0) {
          mergeObjects(matches[0], item);
        } else {
          newArr.push(item);
        }
      }
      for (_j = 0, _len2 = targetArr.length; _j < _len2; _j++) {
        item = targetArr[_j];
        newArr.push(item);
      }
      targetArr.length = 0;
      _results = [];
      for (_k = 0, _len3 = newArr.length; _k < _len3; _k++) {
        item = newArr[_k];
        _results.push(targetArr.push(item));
      }
      return _results;
    };
    for (key in source) {
      val = source[key];
      if (!target[key]) {
        target[key] = val;
      } else {
        if (val) {
          if (val instanceof Array) {
            mergeArrays(target[key], val);
          } else if (typeof val === 'object') {
            mergeObjects(target[key], val);
          }
        }
      }
    }
  };

  mergeLinkedObjects = function(obj, fieldName) {
    if (obj[fieldName]) {
      mergeLinkedObjects(obj[fieldName], fieldName);
      return mergeObjects(obj, obj[fieldName]);
    }
  };

  uniqueId = function(length) {
    var id;
    if (length == null) length = 16;
    id = "";
    while (id.length < length) {
      id += Math.random().toString(36).substr(2);
    }
    return id.substr(0, length);
  };

  dumpError = function(err) {
    if (err) {
      if (typeof err === 'object') {
        if (err.message) console.log('\nMessage: ' + err.message);
      }
      if (err.stack) {
        console.log('\nStacktrace:');
        console.log('====================');
        return console.log(err.stack);
      } else {
        return console.log('dumpError :: argument is not an object');
      }
    } else {
      return console.log('Error is null');
    }
  };

  root.extend = extend;

  root.isComposite = isComposite;

  root.mergeObjects = mergeObjects;

  root.mergeLinkedObjects = mergeLinkedObjects;

  root.uniqueId = uniqueId;

  root.dumpError = dumpError;

}).call(this);
