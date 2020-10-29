/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/**
 * Created by XiongFangyu on 2019-07-19.
 *
 * 消息循环
 *
 * usage:
 * static looper * l;
 * void in_thread() {       // thread 2
 *  l = prepare_loop();
 *  loop();
 * }
 *
 * void msg_handler(L_Message * msg) {
 *  // called in thread 2
 *  switch (msg->type) {
 *      // code
 *  }
 * }
 *
 * void free_msg(L_Message * msg) {
 *  // called when msg not used
 *  free(msg->ud);
 *  free(msg);
 * }
 *
 * static L_Message * create_msg(int type, void *ud) {
 *  L_Message *m = malloc(sizeof(L_Message));
 *  m->utype = type;
 *  m->ud = ud;
 *  m->h = msg_handler;
 *  m->f = free_msg;
 *  return m;
 * }
 *
 * void in_other_thread() { // thread 1
 *  L_Message *m = create_msg(1, some_ud);
 *
 *  if (post_message(l, m) != ML_DONE) {
 *      // code
 *  }
 *
 *  /// exit thread 2
 *  post_quit(l, ML_SAFELY);
 * }
 */

#ifndef MYAPPLICATION_MESSAGE_LOOPER_H
#define MYAPPLICATION_MESSAGE_LOOPER_H
/**
 * 消息循环对象
 */
typedef struct looper looper;
/**
 * 内部内存申请和释放函数
 */
typedef void* (*ml_alloc) (void * p, size_t os, size_t ns);

/**
 * 接收消息并处理的函数
 */
typedef void (*handler)(int type, void *ud);

/**
 * 释放消息内存函数
 */
typedef void (*free_ud)(void *);
/**
 * for post_message
 */
#define ML_DONE         0
#define ML_NO_LOOPER    1
#define ML_QUITING      2
#define ML_WRONG_MSG    3
#define ML_LOCK_FAILED  4

/**
 * for post_quit
 * ML_SAFELY: 将会把消息队列里所有消息执行完再退出
 * ML_UNSAFELY: 消息队列的消息将抛弃
 */
#define ML_SAFELY       1
#define ML_UNSAFELY     0
/**
 * utype
 * 发送quit消息
 */
#define ML_TYPE_QUIT    0xebdcef
#define ML_TYPE_S_QUIT  0xebdcff

/**
 * 为当前线程准备消息循环
 * 创建或从当前线程获取
 * @return 当前线程的消息循环对象
 */
looper *prepare_loop(ml_alloc);

/**
 * 获取当前线程的消息循环对象
 * @return 当前线程的消息循环对象
 */
looper *current_thread_looper(void);

/**
 * 在looper中保存一个自定义类型
 * @return 上次设置的ud
 */
void *save_ud_to_looper(void *, free_ud);

/**
 * 开始消息循环，在线程中必须prepare过
 * 之后的代码在消息循环结束前不会执行到
 */
void loop();

/**
 * 向消息循环发送一条消息
 * @return 状态码 ML_xxx
 */
int post_message(looper *l, int type, void *ud, handler h, free_ud f);

/**
 * 退出消息循环
 * ML_SAFELY, ML_UNSAFELY
 * @return 状态码 ML_xxx
 */
int post_quit(looper *, int);

#endif //MYAPPLICATION_MESSAGE_LOOPER_H