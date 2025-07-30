import redis

# class for the node API
class NodeAPI:
    def __init__(self, hostname='127.0.0.1', port=6379, password=None, flush_on_init=False):
        self.db = redis.Redis(host=hostname, port=port, password=password, decode_responses=True)
        if flush_on_init:
            self.db.flushdb()

    def add_node(self, name, node_type):
        result = self.db.hset(f'node:{str(name)}', mapping={'name': str(name), 'type': node_type})

    def add_edge(self, name1, name2, edge_type):
        result1 = self.db.sadd(f'edge:{str(name1)}:{edge_type}', str(name2))
        result2 = self.db.sadd(f'edge:{str(name2)}:{edge_type}', str(name1))  # Assuming undirected graph

    def get_adjacent(self, name, node_type=None, edge_type=None):
        # obtain edges for a node
        edge_keys = self.db.keys(f'edge:{str(name)}:*')
        adjacent_nodes = set()
        for key in edge_keys:
            if edge_type and not key.endswith(f':{edge_type}'):
                continue
            adjacent = self.db.smembers(key)
            if node_type:
                # filter nodes by type
                adjacent = {node for node in adjacent if self.db.hget(f'node:{node}', 'type') == node_type}
            # use the node keys as the adjacent names
            adjacent_nodes.update(adjacent)

        return list(adjacent_nodes)

    def set_node_props(self, node_id, props):
        # props is expected to be a dict
        for prop, value in props.items():
            if value is not None:
                self.db.hset(f'node:{str(node_id)}', prop, value)

    def get_recommendations(self, name):
        # books bought by the person
        bought_books = self.get_adjacent(name, node_type='Book', edge_type='bought')
        # people that the person knows
        known_people = self.get_adjacent(name, node_type='Person')
        # books bought by known people
        recommended_books = set()
        for person in known_people:
            their_books = self.get_adjacent(person, node_type='Book', edge_type='bought')
            recommended_books.update(their_books)
        # exclude books the person has already bought
        recommended_books.difference_update(bought_books)

        return list(recommended_books)

    # method to test connection to redis
    def test_redis_connection(self):
        # set a test key-value pair
        self.db.set('test_key', 'test_value')
        value = self.db.get('test_key')
        print(f'The value for test_key is: {value}')
