(function() {
  var controller, homeController, storiesController;

  controller = require('./controller');

  homeController = require('./homeController');

  storiesController = require('./storiesController');

  exports.Controller = controller.Controller;

  exports.HomeController = homeController.HomeController;

  exports.StoriesController = storiesController.StoriesController;

}).call(this);
