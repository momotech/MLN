//
// Created by XiongFangyu on 2021/1/21.
//
// 专用树结构

#ifndef MMLUA4ANDROID_MTREE_H
#define MMLUA4ANDROID_MTREE_H

#include <stdlib.h>

#define DEFAULT_STR_SPLIT '.'

#define CONTENT_INIT_SIZE 5

typedef unsigned int hash_t;

typedef void* (*tree_alloc) (void *, size_t, size_t);

typedef hash_t (*tree_hash)(const char *);

typedef int (*tree_equals)(const char *, const char *);
/**
 * 遍历函数，返回0表示继续遍历，1表示遍历完成
 * @see tree_traverse
 * 第一个字符串是遍历给定字符串
 * 第二个字符串为后续字符串拼接结果
 * 第三个数据为自定义数据
 * @return 0:继续，1:不再遍历
 */
typedef int (*tree_look_fun)(const char *, const char *, void *ud);

typedef struct NodeContent {
    hash_t hash;
    char *str;
} NodeContent;

typedef struct TreeNode {
    int size;                   /*size of contents*/
    int use;                    /*contents use size*/
    NodeContent *contents;      /*content array*/
    struct TreeNode *children;  /*child node array*/
} TreeNode;

typedef struct Tree {
    tree_alloc alloc;
    tree_hash hash;
    tree_equals equals;
    char split;
    TreeNode *head; /*size:1*/
} Tree;

Tree *tree_new(tree_alloc);

void tree_free(Tree *);
/**
 * 存储节点
 * @return 1: 存储成功; 0: 失败
 */
int tree_save(Tree *, const char *);
/**
 * 删除节点及后续节点，如存储有a.b.c，删除a.b则会删除a.b.c
 * @return 删除节点数量
 */
int tree_remove(Tree *, const char *);
/**
 * 从给定字符串开始，遍历后续所有key
 * 如: 已有a.b.c、a.b.d、a.b.d.e
 *      给定字符串为a.b
 *      则遍历结果为:c、d、d.e
 */
void tree_traverse(Tree *, tree_look_fun, const char *, void *);

#endif //MMLUA4ANDROID_MTREE_H
