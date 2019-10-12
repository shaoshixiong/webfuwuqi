using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace WEB服务器
{
    /// <summary>
    /// 请求报文实体
    /// </summary>
    public class RequestModel
    {
        /// <summary>
        /// 请求页面路径
        /// </summary>
        string path;
        public string Path
        {
            get { return path; }
            set { path = value; }
        }

        public RequestModel(string strRequest)
        {
            /*
            GET /index.html HTTP/1.1
            Accept: text/html, application/xhtml+xml, *
            */
            string[] arrStr = strRequest.Split(new string[]{"\r\n"},StringSplitOptions.RemoveEmptyEntries);
            string[] arrStrFirstLine = arrStr[0].Split(' ');
            path = arrStrFirstLine[1];// index.html
        }
    }
}
