
DEL_UUID = """
delete from
    collections
where
    user = :user
and
    collection = :collection
"""


ADD_UUID = """
insert into collections
    (user, collection, uuid)
values
    (:user, :collection, :uuid)
"""

GET_UUID = """
select
    uuid
from
    collections
where
    user = :user
and
    collection = :collection
"""


UPDATE_UUID = """
update
    collections
set
    uuid = :uuid
where
    user = :user
and
    collection = :collection
"""


ADD_DEL = """
insert into deleted
    (user, collection, reason, client_id)
values
    (:user, :collection, :reason, :client_id)
"""


REMOVE_DEL = """
delete from
    deleted
where
    user = :user
and
    collection = :collection
"""

IS_DEL = """
select
    client_id, reason
from
    deleted
where
    user = :user
and
    collection = :collection
"""

LAST_MODIFIED = """\
select
    max(last_modified) as last_modified
from
    applications
where
    user = :user
and
    collection = :collection
"""


GET_QUERY = """\
select
    last_modified, data
from
    applications
where
    user = :user
and
    collection = :collection
and
    last_modified > :since
order by
    last_modified
"""


GET_BY_ORIGIN_QUERY = """\
select
    id, data
from
    applications
where
    user = :user
and
    collection = :collection
and
    origin = :origin
"""


UPDATE_BY_ORIGIN_QUERY = """\
update applications
set
    data = :data, last_modified = :last_modified
where
    user = :user
and
    collection = :collection
and
    id = :id
"""


# XXX no bulk inserts in sqlite
PUT_QUERY = """
insert into applications
    (user, collection, last_modified, data, origin)
values
    (:user, :collection, :last_modified, :data, :origin)
"""


DEL_QUERY = """
delete from
    applications
where
    user = :user
and
    collection = :collection
"""
