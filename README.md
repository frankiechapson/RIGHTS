
# User rights

## How to manage users/user groups and their rights to the menus/functions


Almost every application has an authorization system.

Here is my abstract implementation of this issue:

* There is structure of functions and menu items of an application.
* There is another structure of users and their user groups.
* There are some connection between nodes of these two structure:

Figure:

    APPL 1                <---------------------- A -------------------->       ADMINS
       |                                                                           |
       +-- HR MODUL       <-----------------------+                                +-- SA
       |    |                                     |                                |
       |    +-- HR MENU 1                         |                                +-- FERI
       |    |       |                             |                                    
       |    |       +-- HR FUNC 1                 E                                    
       |    |                                     |                            READERS   
       |    +-- HR MENU 2                         |                                |
       |            |                             |                                +-- JOHN
       |            +-- HR FUNC 2                 |                                |
       |                                          +--------------------->          +-- HR
       |                                                                           |    |
       +-- IT MODUL       <-----------------------+                                |    |
       |    |                                     |                                |    +-- MARY
       |    +-- IT MENU 1                         E                                |
       |    |       |                             |                                |
       |    |       |                             +--------------------->          +-- IT   
       |    |       +-- IT FUNC 1    <----+                                             |
       |    |                             |                                             +-- FRANK
       |    +-- IT MENU 2                 +--------- E ----------------->       HENRY              
       |            |                                                    
       |            +-- IT FUNC 2                                                  ^
       |                                                                           |
       +-- ZZ MODUL                                                                |
       |    |                                                                      |
       |    +-- ZZ MENU 1                                                          |
       |    |       |                                                               
       |    |       +-- ZZ FUNC 1                                                  E
       |    |                                                                       
       |    +-- ZZ MENU 2                                                          |
       |            |                                                              |
       |            +-- ZZ FUNC 2                                                  |
       |                                                                           |
       +-- FUNC 00       <---------------------------------------------------------+


The rules of the authorization system:
* if a user can access a function (node), then she/he have to access every parents of this function too
* if a user can access a menu point (node), then she/he can access every children of this menu point too

The functions of the authorization system:
* who and how can access a menu point/function (node)?
* which menu point/function and how is reachable for a user/user group?
* is reachable a certain menu point/function for a certain user/user group?

