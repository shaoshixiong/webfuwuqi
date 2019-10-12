using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WEB服务器
{
    /// <summary>
    /// 响应报文实体类
    /// </summary>
    public class ResponseModel
    {
        string strContentType;
        int contentLength = 0;
        byte[] arrContentBody;

        public int ContentLength 
        {
            get { return contentLength; }
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="strFileExtention">文件后缀名</param>
        /// <param name="arrContentBody">响应报文体</param>
        public ResponseModel(string strFileExtention,byte[] arrContentBody) 
        {
            //1 获得响 应报文的ContentType
            strContentType = GetContentTypeByFileExtention(strFileExtention);
            //2 设置相应报文体
            this.arrContentBody = arrContentBody;                
            //3 设置响应报文体的数据长度
            this.contentLength = arrContentBody.Length;
        }

        #region 1.0 根据文件后缀获得Content-Type值 - GetContentTypeByFileExtention(string fileExtention)
        /// <summary>
        /// 根据文件后缀获得Content-Type值
        /// </summary>
        /// <param name="fileExtention"></param>
        /// <returns></returns>
        string GetContentTypeByFileExtention(string fileExtention)
        {
            switch (fileExtention) 
            {
                case ".jpg":
                    return "image/jpeg";
                case ".aspx":
                case ".ashx":
                case ".jsp":
                case ".php":
                case ".html":
                    return "text/html";
                case ".js":
                    return "text/javascript";
                default:
                    return "text/html";
            }
        } 
        #endregion

        #region 2.0 获得响应报文头 + GetResponseHeader()
        /// <summary>
        /// 2.0 获得响应报文头
        /// </summary>
        /// <returns></returns>
        public byte[] GetResponseHeader()
        {
            /*
            * HTTP/1.1 200 ok
               Content-Type: text/html;charset=utf-8
               Content-Length: 325
            */
            StringBuilder sbHeader = new StringBuilder();
            sbHeader.AppendFormat("HTTP/1.1 200 ok\r\n");
            sbHeader.AppendFormat("Content-Type:{0};charset=utf-8\r\n", strContentType);
            sbHeader.AppendFormat("Content-Length:{0}", contentLength);
            return Encoding.UTF8.GetBytes(sbHeader.ToString());
        } 
        #endregion

        #region 3.0获得响应报文体 + GetContentBody()
        /// <summary>
        /// 3.0获得响应报文体
        /// </summary>
        /// <returns></returns>
        public byte[] GetContentBody()
        {
            return arrContentBody;
        } 
        #endregion
    }
}
