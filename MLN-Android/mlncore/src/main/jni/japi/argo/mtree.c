//
// Created by XiongFangyu on 2021/1/21.
//

#include <string.h>
#include "mtree.h"

#define index_of(h, s) (unsigned int)((h) % (s))

static hash_t str_hash(const char *s) {
    int h = 0;
    for (; *s; s++)
        h = *s + h * 31;
    return h;
}

static int str_equals(const char *a, const char *b) {
    return strcmp(a, b) == 0;
}

Tree *tree_new(tree_alloc f) {
    if (!f) return NULL;
    Tree *tree = (Tree *) f(NULL, 0, sizeof(Tree));
    if (!tree) return NULL;
    TreeNode *head = (TreeNode *) f(NULL, 0, sizeof(TreeNode));
    if (!head) {
        f(tree, sizeof(Tree), 0);
        return NULL;
    }
    memset(head, 0, sizeof(TreeNode));
    tree->alloc = f;
    tree->equals = str_equals;
    tree->hash = str_hash;
    tree->split = DEFAULT_STR_SPLIT;
    tree->head = head;
    return tree;
}

static inline void free_node(tree_alloc f, TreeNode *node) {
    for (int i = 0; i < node->size; ++i) {
        NodeContent *c = &node->contents[i];
        if (c->str) {
            f(c->str, (strlen(c->str) + 1) * sizeof(char), 0);
            free_node(f, &node->children[i]);
        }
    }
    f(node->contents, sizeof(NodeContent) * node->size, 0);
    f(node->children, sizeof(TreeNode) * node->size, 0);
}

void tree_free(Tree *tree) {
    TreeNode *node = tree->head;
    free_node(tree->alloc, node);
    tree->alloc(node, sizeof(TreeNode), 0);
    tree->alloc(tree, sizeof(Tree), 0);
}

static inline int find(TreeNode *node, const char *key, hash_t h) {
    unsigned int idx = index_of(h, node->size);
    int first = 1;
    NodeContent *contents = node->contents;
    unsigned int i;
    for (i = idx; i != idx || first == 1; i = index_of(i + 1, node->size)) {
        first = 0;
        if (contents[i].hash != h) continue;
        if (strcmp(contents[i].str, key) == 0) {
            first = -1;
            break;
        }
    }
    if (!first) return -1;
    return (int) i;
}

/**
 * 将str存放到contents中
 * @param check 是否检查相同key，若有相同key，将check值改为1
 * @return 返回对应TreeNode
 */
static inline TreeNode *put(NodeContent *old_con, TreeNode *old_child,
                             NodeContent *new_contents, TreeNode *new_children,
                             int newsize, int *check) {
    unsigned int idx = index_of(old_con->hash, newsize);
    while (new_contents[idx].str) {
        if (check) {
            if (strcmp(new_contents[idx].str, old_con->str) == 0) {
                *check = 1;
                return &new_children[idx];
            }
        }
        idx = index_of(idx + 1, newsize);
    }
    memcpy(&new_contents[idx], old_con, sizeof(NodeContent));
    if (old_child)
        memcpy(&new_children[idx], old_child, sizeof(TreeNode));
    return &new_children[idx];
}

static inline void rehash(NodeContent *old_con, TreeNode *old_children, int oldsize,
                           NodeContent *new_con, TreeNode *new_children, int newsize) {
    for (int i = 0; i < oldsize; ++i) {
        put(&old_con[i], &old_children[i],
             new_con, new_children,
             newsize, 0);
    }
}

/**
 * 存入key到node里，自动分离key
 * @return 1: 存储成功，0: 失败
 */
static inline int save(Tree *tree, TreeNode *node, const char *key) {
    /// 未初始化
    if (node->size == 0) {
        node->contents = (NodeContent *) tree->alloc(NULL, 0,
                                                     sizeof(NodeContent) * CONTENT_INIT_SIZE);
        if (!node->contents) return 0;
        node->children = (TreeNode *) tree->alloc(NULL, 0, sizeof(TreeNode) * CONTENT_INIT_SIZE);
        if (!node->children) {
            tree->alloc(node->contents, sizeof(NodeContent) * CONTENT_INIT_SIZE, 0);
            return 0;
        }
        node->size = CONTENT_INIT_SIZE;
        node->use = 0;
        memset(node->contents, 0, sizeof(NodeContent) * CONTENT_INIT_SIZE);
        memset(node->children, 0, sizeof(TreeNode) * CONTENT_INIT_SIZE);
    }
        /// 满了
    else if (node->use >= node->size) {
        int newsize = node->size + CONTENT_INIT_SIZE;
        NodeContent *new_contents = (NodeContent *) tree->alloc(NULL, 0,
                                                                sizeof(NodeContent) * newsize);
        if (!new_contents) return 0;
        TreeNode *new_children = (TreeNode *) tree->alloc(NULL, 0, sizeof(TreeNode) * newsize);
        if (!new_children) {
            tree->alloc(new_contents, sizeof(TreeNode) * newsize, 0);
            return 0;
        }
        memset(new_contents, 0, sizeof(NodeContent) * newsize);
        memset(new_children, 0, sizeof(TreeNode) * newsize);
        rehash(node->contents, node->children, node->size,
                new_contents, new_children, newsize);
        tree->alloc(node->contents, sizeof(NodeContent) * node->size, 0);
        tree->alloc(node->children, sizeof(TreeNode) * node->size, 0);
        node->contents = new_contents;
        node->children = new_children;
        node->size = newsize;
    }

    /// 存放
    char *real_key;
    size_t real_key_len;
    size_t len = strlen(key);
    char *split_index = strchr(key, tree->split);
    if (split_index) {
        real_key_len = split_index - key;
    } else {
        real_key_len = len;
    }
    real_key = tree->alloc(NULL, 0, sizeof(char) * (real_key_len + 1));
    if (!real_key) return 0;
    memcpy(real_key, key, real_key_len);
    real_key[real_key_len] = '\0';

    hash_t key_hash = tree->hash(real_key);
    NodeContent temp = {key_hash, real_key};
    int check = 0;
    TreeNode *child = put(&temp, NULL,
                           node->contents, node->children,
                           node->size, &check);
    if (check == 1) {
        /// 有相同key
        tree->alloc(real_key, sizeof(char) * (real_key_len + 1), 0);
    } else {
        node->use++;
    }

    /// 若有子key，存放
    if (split_index) {
        return save(tree, child, &split_index[1]);
    }
    return 1;
}

/**
 * 将key存到树里
 * @return 1: 存储成功，0: 失败
 */
int tree_save(Tree *tree, const char *key) {
    return save(tree, tree->head, key);
}

static inline int remove_node(tree_alloc f, TreeNode *node) {
    if (node->use == 0)
        return 0;
    int remove_count = 0;
    for (int i = 0; i < node->size; ++i) {
        char *str = node->contents[i].str;
        if (str) {
            f(str, (strlen(str) + 1) * sizeof(char), 0);
            remove_count += remove_node(f, &node->children[i]) + 1;
        }
    }
    f(node->contents, sizeof(NodeContent) * node->size, 0);
    f(node->children, sizeof(TreeNode) * node->size, 0);
    node->size = 0;
    node->use = 0;
    return remove_count;
}

/**
 * 查找最后一级key的父节点，并在last_index给出最后一级key在父节点中的位置
 * @return 没查找到返回NULL
 */
static inline TreeNode *
find_traverse(Tree *tree, TreeNode *node, const char *key, int *last_index) {
    if (node->use <= 0)
        return NULL;
    /// 找到第一级key
    static const int _max = 100;
    char real_key[_max] = {0};
    size_t real_key_len;

    char *split_index = strchr(key, tree->split);
    int idx;
    while (split_index) {
        if (node->use <= 0) {
            node = NULL;
            break;
        }
        real_key_len = split_index - key;
        memcpy(real_key, key, real_key_len);
        real_key[real_key_len] = '\0';

        idx = find(node, real_key, tree->hash(real_key));
        if (idx < 0) {
            node = NULL;
            break;
        }
        node = &node->children[idx];
        key = &split_index[1];
        split_index = strchr(key, tree->split);
    }
    if (!node)
        return NULL;
    idx = find(node, key, tree->hash(key));
    if (idx < 0)
        return NULL;
    if (last_index)
        *last_index = idx;
    return node;
}

/**
 * 删除节点及后续节点，如存储有a.b.c，删除a.b则会删除a.b.c
 * @return 删除节点数量
 */
int tree_remove(Tree *tree, const char *key) {
    TreeNode *node = tree->head;
    int idx = 0;
    node = find_traverse(tree, node, key, &idx);
    if (!node)
        return 0;
    node->use--;
    NodeContent *c = &node->contents[idx];
    c->hash = 0;
    tree->alloc(c->str, sizeof(char) * (strlen(c->str) + 1), 0);
    c->str = NULL;
    return remove_node(tree->alloc, &node->children[idx]) + 1;
}

static inline void traverse_callback(TreeNode *node,
                                      const char split,
                                      const char *skey,
                                      char *pkey,
                                      const size_t idx,
                                      tree_look_fun lf,
                                      void *ud) {
    if (node->use == 0)
        return;
    NodeContent *content;
    size_t klen;
    for (int i = 0; i < node->size; ++i) {
        content = &node->contents[i];
        if (content->str) {
            klen = strlen(content->str);
            memcpy(&pkey[idx], content->str, klen);
            pkey[idx + klen] = '\0';
            if (lf(skey, pkey, ud))
                return;
            pkey[idx + klen] = split;
            traverse_callback(&node->children[i], split, skey, pkey, idx + klen + 1, lf, ud);
        }
    }
}

void tree_traverse(Tree *tree, tree_look_fun lf, const char *key, void *ud) {
    TreeNode *node = tree->head;
    int idx = 0;
    node = find_traverse(tree, node, key, &idx);
    if (!node)
        return;
    node = &node->children[idx];
    static const size_t _max = 300;
    char pkey[_max];
    traverse_callback(node, tree->split, key, pkey, 0, lf, ud);
}
