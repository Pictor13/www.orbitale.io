---
layout: post
title:  "Doctrine tools"
date:   2015-12-28 22:17:44 +0200
---

Some useful tools to improve Doctrine ORM experience.

## New class: BaseEntityRepository

### New methods

* `$indexBy` : <small>The methods `findAllRoot`, `findAllArray`, `findBy`, and `findAll` accept a last argument allowing
to index the returned array with the value from one of the entity properties (by default, primary key, if set to 
`true`)</small>
* `findAllRoot` : <small>Retrieves only "root" objects, without any join of associated entities. **Note:** Cancels the 
effects of `fetch="EAGER"` on the entity.</small>
* `findAllArray` : <small>Executes `findAllRoot` but returns the result as PHP array.</small>
* `sortCollection` : <small>Use to index an array of entities based on one of its properties, mostly a unique index.
Default is set to the primary key.</small>
* `getIds` : <small>Returns all "id" values from the database in an array.</small>

## New class: AbstractFixture

<small>To be used with `doctrine/data-fixtures` and/or `doctrine/doctrine-fixtures-bundle`.</small>

You can now add your fixtures directly in a PHP array, like from a PhpMyAdmin export for example. It is also possible
to specify the fixtures priority, and a potential prefix to be used to create references of each fixture reusable in
other fixtures classe. The prefix will be appended by the "id" if specified, or the string representation of the entity
if not. **Bonus:** If you specify an "id", it will be inserted as-is.

{% highlight php %}
use Orbitale\Component\DoctrineTools\AbstractFixture;

class PostFixtures extends AbstractFixture
{
   public function getEntityClass() {
       return 'AppBundle\Entity\Post';
   }

   public function getObjects() {
       return [
           ['id' => 1, 'title' => 'First post', 'description' => 'Lorem ipsum'],
           ['id' => 2, 'title' => 'Second post', 'description' => 'muspi meroL'],
       ];
   }

   public function getOrder() {
       return 1;
   }

   protected function getReferencePrefix() {
       return 'posts-';
   }
}
{% endhighlight %}

[View on Github](https://github.com/Orbitale/DoctrineTools)
