using GZCZBKWeb服务器;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace WEB服务器
{
    /// <summary>
    /// 请求处理类，根据请求报文对象生成相应报文对象
    /// </summary>
    public class RequestAnalyse
    {
        RequestModel requestModel;
        DGShowInfo dgShowMsg;

        /// <summary>
        /// 获取的报文请求对象
        /// </summary>
        public RequestAnalyse(RequestModel requestModel, DGShowInfo dgShowMsg)
        {
            this.requestModel = requestModel;
            this.dgShowMsg = dgShowMsg;
        }

        #region 1.0 根据文件后缀处理 请求，并返回 响应报文实体对象 + ProcessWithExtention()
        /// <summary>
        /// 根据文件后缀处理 请求，并返回 响应报文实体对象
        /// </summary>
        public ResponseModel ProcessWithExtention()
        {
            ResponseModel responseModel = null;
            //1.1获取被请求文件的后缀
            string strFileExtention = System.IO.Path.GetExtension(requestModel.Path);
            switch (strFileExtention.ToLower())
            {
                case ".html":
                case ".css":
                case ".js":
                    //1.2 处理静态页面
                    responseModel = ProcessStaticPage(requestModel.Path);
                    break;
                case ".jpg":
                case ".gif":
                case ".png":
                    //1.3 处理图片
                    responseModel = ProcessImage(requestModel.Path);
                    break;
                case ".aspx":
                case ".ashx":
                case ".jsp":
                case ".php":
                    //1.4 处理动态页面
                    responseModel = ProcessAyn(requestModel.Path);
                    break;
            }
            return responseModel;
        }


        #endregion

        #region 2.0 根据路径读取静态页面内容，并返回响应报文对象 - ProcessStaticPage(string strPath)
        /// <summary>
        /// 根据路径读取静态页面内容，并返回响应报文对象
        /// </summary>
        ResponseModel ProcessStaticPage(string strPath)
        {
            //获取当前程序集的文件夹路径
            string dataDir = AppDomain.CurrentDomain.BaseDirectory;
            //获得被请求文件的物理路径
            dataDir += "" + requestModel.Path;
            //一次性读取文件的所有的数据
            string strFileContent = File.ReadAllText(dataDir);
            //将请求文件数据 转成字节数组
            byte[] arrFileBody = Encoding.UTF8.GetBytes(strFileContent);
            //创建 相应报文实体对象 ， 并传入 后缀名和 响应报文数据
            return new ResponseModel(Path.GetExtension(strPath), arrFileBody);
        }
        #endregion

        #region 3.0 根据路径读取图片内容，并返回响应报文对象 - ProcessImage(string strPath)
        /// <summary>
        /// 3.0 根据路径读取图片内容，并返回响应报文对象
        /// </summary>
        /// <param name="strPath"></param>
        /// <returns></returns>
        private ResponseModel ProcessImage(string strPath)
        {
            //另一种方式获得正在运行程序集的路径
            string webPath = AppDomain.CurrentDomain.BaseDirectory;
            using (FileStream fs = new FileStream(webPath + strPath, FileMode.Open))
            {
                byte[] arr = new byte[1024 * 1024 * 2];
                int length = fs.Read(arr, 0, arr.Length);
                byte[] arrNew = new byte[length];
                Buffer.BlockCopy(arr, 0, arrNew, 0, length);
                return new ResponseModel(Path.GetExtension(strPath), arrNew);
            }
        }
        #endregion

        #region 4.0 根据路径处理动态页面，并返回响应报文对象 -ResponseModel ProcessAyn(string strPath)
        /// <summary>
        /// 4.0 根据路径处理动态页面，并返回响应报文对象 -ResponseModel ProcessAyn(string strPath)
        /// </summary>
        /// <param name="strPath"></param>
        /// <returns></returns>
        private ResponseModel ProcessAyn(string strPath)// ClassList.aspx
        {
            //获得去掉后缀名的文件名，然后加上 命名空间名称，组合成一个 类的全名称
            string strFileWithOutExtention = Path.GetFileNameWithoutExtension(strPath);// ClassList
            string className = "GZCZBKWeb服务器." + strFileWithOutExtention;//类的全名称：GZCZBKWeb服务器.ClassList
            //获得当前程序集
            Assembly asse = Assembly.GetExecutingAssembly();
            //获得当前程序集里指定名称的 类型 如:ClassList
            Type t = asse.GetType(className);
            //反射创建类的对象 
            object o = Activator.CreateInstance(t); // new ClassList
            //转成接口
            IHttpHanlder iPage = o as IHttpHanlder;
            //调用 接口 的 PR 方法，获得 生成的页面html字符串
            string strHtml = iPage.ProcessRequest();
            //封装到 响应报文实体对象中，并返回
            return new ResponseModel(Path.GetExtension(strPath), Encoding.UTF8.GetBytes(strHtml));
        }
        #endregion
    }
}
