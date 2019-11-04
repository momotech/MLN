//
// Created by XiongFangyu on 2019-07-19.
//

#include <pthread.h>
#include <stdlib.h>
#include "message_looper.h"

#define S_INIT      (char) 0
#define S_LOOP      (char) 1
#define S_QUITING   (char) 2
#define S_QUIT      (char) 3

/**
 * 消息对象
 */
typedef struct L_Message {
    int utype;      /*用户自定义类型*/
    void *ud;       /*用户自定义数据*/
    handler h;      /*接收消息函数，必须设置*/
    free_ud f;      /*释放message函数，必须设置*/
    struct L_Message *next;
} L_Message;

struct looper {
    char state;
    L_Message *head;
    L_Message *tail;
    pthread_mutexattr_t attr;
    pthread_mutex_t lock;
    pthread_cond_t cond;
    void *ud;
    free_ud f;
    ml_alloc alloc;
};

static void *default_alloc(void * p, size_t os, size_t ns) {
    if (ns == 0) {
        free(p);
        return NULL;
    } else {
        return realloc(p, ns);
    }
}

static pthread_once_t gTOnce = PTHREAD_ONCE_INIT;
static pthread_key_t gTKey = 0;

static void _free_loop(void* ud);
static void initTKey() {
    pthread_key_create(&gTKey, _free_loop);
}

looper *current_thread_looper(void) {
    pthread_once(&gTOnce, initTKey);
    return (looper *) pthread_getspecific(gTKey);
}

void *save_ud_to_looper(void *ud, free_ud f) {
    looper *cl = current_thread_looper();
    void *last = cl->ud;
    cl->ud = ud;
    cl->f = f;
    return last;
}

static L_Message *new_message(looper *l, int type, void *ud, handler h, free_ud f) {
    L_Message *m = l->alloc(NULL, 0, sizeof(L_Message));
    m->utype = type;
    m->ud = ud;
    m->f = f;
    m->h = h;
    m->next = NULL;
    return m;
}

looper *prepare_loop(ml_alloc alloc) {
    looper *l = current_thread_looper();
    if (l) return l;
    alloc = (alloc) ? alloc : default_alloc;
    l = (looper *) alloc(NULL, 0, sizeof(looper));
    l->state = S_INIT;
    l->alloc = alloc;
    l->ud = NULL;
    l->f = NULL;
    l->head = new_message(l, 0, NULL, NULL, NULL);
    l->tail = l->head;
    pthread_mutexattr_init(&l->attr);
    pthread_mutexattr_settype(&l->attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&l->lock, &l->attr);
    pthread_cond_init(&l->cond, NULL);
    pthread_setspecific(gTKey, l);
    return l;
}

static L_Message *poll_once(looper *l) {
    if (pthread_mutex_lock(&l->lock) != 0) {
        return NULL;
    }
    while (!l->head->next)
        pthread_cond_wait(&l->cond, &l->lock);
    L_Message *ret = l->head->next;
    l->head->next = ret->next;
    if (l->tail == ret) {
        l->tail = l->head;
    }
    pthread_mutex_unlock(&l->lock);
    return ret;
}

int post_message(looper *l, int type, void *ud, handler h, free_ud f) {
    int ret;
    if (pthread_mutex_lock(&l->lock) != 0) {
        return ML_LOCK_FAILED;
    }
    if (l->state == S_QUITING || l->state == S_QUIT) {
        ret = ML_QUITING;
        if (f) f(ud);
    } else if (!h) {
        ret = ML_WRONG_MSG;
        if (f) f(ud);
    } else {
        if (type == ML_TYPE_S_QUIT || type == ML_TYPE_QUIT)
            l->state = S_QUITING;
        L_Message *msg = new_message(l, type, ud, h, f);
        if (type == ML_TYPE_QUIT) {
            L_Message *pn = l->head->next;
            l->head->next = msg;
            msg->next = pn;
        } else {
            l->tail->next = msg;
            l->tail = msg;
        }
        pthread_cond_signal(&l->cond);
        ret = ML_DONE;
    }
    pthread_mutex_unlock(&l->lock);
    return ret;
}

static void _free_loop(void* ud) {
    looper *l = (looper *) ud;
    if (!l) return;

    while (l->head->next) {
        if (l->head->next->f)
            l->head->next->f(l->head->next->ud);
        l->head->next = l->head->next->next;
        l->alloc(l->head->next, sizeof(L_Message), 0);
    }
    l->alloc(l->head, sizeof(L_Message), 0);
    pthread_mutex_destroy(&l->lock);
    pthread_cond_destroy(&l->cond);
    pthread_mutexattr_destroy(&l->attr);
    if (l->ud && l->f) l->f(l->ud);
    l->ud = NULL;
    l->alloc(l, sizeof(looper), 0);
}

void loop() {
    looper *l = current_thread_looper();
    if (pthread_mutex_lock(&l->lock) != 0) {
        return;
    }
    if (!l || l->state == S_LOOP || l->state == S_QUITING || l->state == S_QUIT) {
        return;
    }
    l->state = S_LOOP;
    pthread_mutex_unlock(&l->lock);
    while (1) {
        if (l->state == S_QUIT) break;

        L_Message *msg = poll_once(l);
        if (!msg) break;

        msg->h(msg->utype, msg->ud);
        l->alloc(msg, sizeof(L_Message), 0);
    }
}

static void _handle_quit_message(int type, void *ud) {
    looper *l = current_thread_looper();
    pthread_mutex_lock(&l->lock);
    l->state = S_QUIT;
    pthread_mutex_unlock(&l->lock);
}

int post_quit(looper *l, int type) {
    int mtype;
    if (type == ML_SAFELY) {
        mtype = ML_TYPE_S_QUIT;
    } else if (type == ML_UNSAFELY) {
        mtype = ML_TYPE_QUIT;
    } else {
        return ML_WRONG_MSG;
    }
    return post_message(l, mtype, NULL, _handle_quit_message, NULL);
}
