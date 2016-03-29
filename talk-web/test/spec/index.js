/**
 * Entry point for all unit tests
 */

require('./polyfill');

/**
 * Global configs goes here
 */
window._initialStore = {config: {}};

Q = require('q');

/**
 * Create a set of webpack module ids for our project's modules, excluding
 * tests. This will be used to clear the module cache before each test.
 */
var clientContext = require.context('../../client/', true, /.+\.coffee?$/);
var configContext = require.context('../../config/', true, /.+\.coffee?$/);
var clientModuleIds = clientContext.keys().map(function(module) {
  return String(clientContext.resolve(module));
});
var configModuleIds = configContext.keys().map(function(module) {
  return String(configContext.resolve(module));
});
var projectModuleIds = clientModuleIds.concat(configModuleIds);

beforeEach(function() {
  /**
   * Clear the module cache before each test. Many of our modules, such as
   * Stores and Actions, are singletons that have state that we don't want to
   * carry over between tests. Clearing the cache makes `require(module)`
   * return a new instance of the singletons. Modules are still cached within
   * each test case.
   */
  projectModuleIds.forEach(function(id) {
    delete require.cache[id];
  });

  /**
   * Mock reqwest globally
   */
  require('reqwest');
  reqwest = jasmine.createSpy('reqwest').and.returnValue(Q.when());
  require.cache[require.resolve('reqwest')].exports = reqwest;

  /**
   * Automatically mock the built in setTimeout and setInterval functions.
   * Use jasmine.clock().tick() for triggering the next tick.
   */
  jasmine.clock().install();

  /**
   * Define Immutable-js matchers
   */
  jasmine.addMatchers({
    toEqualImmutable: function(expected) {
      return {
        compare: function(actual, expected) {
          var result = {};
          result.pass = require('immutable').is(actual, expected);
          if (result.pass) {
            result.message = "Expected " + JSON.stringify(actual.toJS()) + " not to equal " + JSON.stringify(expected.toJS());
          } else {
            result.message = "Expected " + JSON.stringify(actual.toJS()) + " to equal " + JSON.stringify(expected.toJS());
          }
          return result;
        }
      };
    }
  });

});

afterEach(function() {
  jasmine.clock().uninstall();
});

/**
 * Load each test using webpack's dynamic require with contexts.
 */
var context = require.context('.', true, /.+\.spec\.coffee?$/);
context.keys().forEach(context);
