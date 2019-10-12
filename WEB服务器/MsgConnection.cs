using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Text;

namespace WEB服务器
{
    /// <summary>
    /// 通讯处理类
    /// </summary>
    public class MsgConnection
    {
        Socket socket;
        DGShowInfo dgShowInfo;
        Thread thread;
        public MsgConnection(Socket socket,DGShowInfo dgShowInfo ) 
        {
            this.socket = socket;
            this.dgShowInfo = dgShowInfo;
            BeginThread();
        }

        bool isReceive = true;

        #region 1.0 开启线程接收信息 + BeginThread()
        /// <summary>
        /// 1.0 开启线程接收信息
        /// </summary>
        private void BeginThread()
        {
            thread = new Thread(ReceiveMsg);
            thread.IsBackground = true;
            thread.Start();
        } 
        #endregion

        #region 2.0 循环等待接收信息 + ReceiveMsg()
        /// <summary>
        ///  2.0 循环等待接收信息
        /// </summary>
        void ReceiveMsg()
        {
            try
            {
                while (isReceive)
                {
                    byte[] btMsg = new byte[1024 * 1024];
                    //接收浏览器数据，并获得真实接收到的数据长度
                    int length = socket.Receive(btMsg);
                    //将请求报文转成字符串
                    string strMsg = Encoding.UTF8.GetString(btMsg);
                    dgShowInfo("*********************已接受浏览器端消息*********************\r\n");
                    //1.将请求报文字符串 封装到 请求报文实体对象中
                    RequestModel req = new RequestModel(strMsg);
                    //2.根据请求报文里的请求路径，读取相对应的文件数据，并生成响应报文
                    RequestAnalyse analyse = new RequestAnalyse(req, dgShowInfo);
                    //3.调用分析类对象的处理方法，最终生成响应报文实体对象
                    ResponseModel resp = analyse.ProcessWithExtention();
                    //4.发送响应报文数据
                    socket.Send(resp.GetResponseHeader());//发送响应报文头

                    socket.Send(Encoding.UTF8.GetBytes("\r\n\r\n"));//发送换行!!!!!!!!!!!!!!!!!!!!!!!!!!!!!记住，一定要换行！（http协议通过空行区别报文头和报文体）

                    socket.Send(resp.GetContentBody());//发送响应包文体

                    dgShowInfo("*********************发送响应报文完毕***********************\r\n");
                    isReceive = false;
                    socket.Shutdown(SocketShutdown.Both);
                    socket.Close();
                }
            }
            catch (Exception)
            {
                dgShowInfo("*********************浏览器客户端已断开*********************\r\n");
                isReceive = false;
                if (thread.IsAlive)
                    thread.Abort();
            }
        } 
        #endregion
    }

    public delegate void DGShowInfo(string Msg);
}
