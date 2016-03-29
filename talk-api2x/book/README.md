Talk.ai
===

The missing chat Saas & Cloud application for everyone

# Structure
```
- app
  - components      Framework components
  - config          Application configs
  - controllers     Application controllers
    - mixins        Share code between controllers by mixins
  - blls            Business Logic Layer connect controller and model
  - helpers         Helper methods share between different classes, if you think your controller is overstaffed and need share some code to other controllers, use helper
  - kits            Useful tool kits
  - mailers         Codes deal with mails
  - middlewares     Middlewares for specific usage
  - schemas         Mongoose schemas and basic limbo manager
  - util            Utility static methods
```
