---
layout: post
title:  "Manage FOSUser in EasyAdmin"
date:   2015-12-28 22:27:20 +0200
---

Last modified: 2018-08-27 09:56

Edit (2018-08-27): FOSUserBundle is not the recommended way of managing users. If you want a nice user manager, please
write it yourself to avoid FOSUser's inheritance and overriding hell. If you want a nice course about it, check out
[KNPUniversity's Symfony Security screencast](https://knpuniversity.com/screencast/symfony-security) for best practices.

[EasyAdmin](https://github.com/javiereguiluz/EasyAdminBundle) is a powerful backend generator, which creates magic with
a simple `Yaml` file.

However, it has no support of FOSUserBundle, thanks to a specific opinion of the creator not to add too many "bridges"
to the bundle for it to be the lightest possible.

But as EasyAdmin is great, we can easily implement users management directly in EasyAdmin.

As FOSUser uses some services to manage users, we have to add some logic inside our `AdminController` to make it work
properly.

We assume here that you already have EasyAdmin installed on your app.

*  First, [Install FOSUserBundle](https://symfony.com/doc/master/bundles/FOSUserBundle/index.html) and set it up to work
the way you want. It might take you some time if you have not used it before, if so, feel free to take the time you need
to know how FOSUserBundle works.
*  Then, add this config for EasyAdmin: {% highlight yaml %}
easy_admin:
   entities:
       Users:
           class: AppBundle\Entity\User
           list:
               fields:
                   - id
                   - username
                   - email
           form:
               fields:
                   - username
                   - email
                   - roles
                   - enabled
{% endhighlight %}
*   If you do not have one already,
[create your own AdminController](https://symfony.com/doc/current/bundles/EasyAdminBundle/book/complex-dynamic-backends.html#customization-based-on-entity-controllers)
extending EasyAdmin's one. Test it in your browser. You should see the
`User` entity in your EasyAdmin menu.
*   Add these three methods to your controller:
{% highlight php %}
public function createNewUsersEntity()
{
  return $this->container->get('fos_user.user_manager')->createUser();
}

public function prePersistUsersEntity(User $user)
{
  $this->container->get('fos_user.user_manager')->updateUser($user, false);
}

public function preUpdateUsersEntity(User $user)
{
  $this->container->get('fos_user.user_manager')->updateUser($user, false);
}
{% endhighlight %}

And you're done for user management!

You can manually add other fields, but the most important is here. Easy, isn't it? For groups, it's very similar:
activate groups management with FOSUserBundle, and add the `groups` field to your EasyAdmin's User entity configuration
under the `form` parameter.

Indeed you should manage groups as well so if you don't have groups, you can't set a group for a user, so you must
create a backend for your Group entity. And as EasyAdmin is easy, you can do it yourself very easily!
