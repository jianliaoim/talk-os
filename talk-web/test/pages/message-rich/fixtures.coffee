dataUri = require './data-uri'
module.exports = [
## file ##
  category: 'file'
  data:
    fileType: 'js'
    fileName: 'hey'
    fileSize: 686786
    fileCategory: 'text'
    downloadUrl: 'localhost:8080'
  category: 'file'
,
  category: 'file'
  data:
    fileType: 'docx'
    fileName: 'hey'
    fileSize: 7987979
    fileCategory: 'application'
    downloadUrl: 'localhost:8080'
,
## image ##
  category: 'image'
  data:
    thumbnailUrl: 'https://dn-talk.oss.aliyuncs.com/icons/preview.png'
    imageWidth: 300
    imageHeight: 300
    fileCategory: 'image'
,
  # 上传中, 本地图片
  category: 'image'
  data:
    thumbnailUrl: dataUri.one
    imageWidth: 400
    imageHeight: 300
    fileCategory: 'image'
  isUploading: true
  progress: 0.5
,
  # 上传完毕
  category: 'image'
  data:
    thumbnailUrl: dataUri.two
    imageWidth: 400
    imageHeight: 300
    fileCategory: 'image'
  isUploading: false
  progress: 1
,
  # 错误的url
  category: 'image'
  data:
    thumbnailUrl: 'asdf'
    imageWidth: 200
    imageHeight: 200
,
## quote ##
  category: 'quote'
  data:
    redirectUrl: 'http://jianliao.com'
    text: '''
      Lorem &nbsp; Ipsum &nbsp; is &nbsp; simply &nbsp; dummy &nbsp; text &nbsp; of &nbsp; the &nbsp; printing &nbsp; and &nbsp; typesetting &nbsp; industry.\n
      Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n
      It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n
      '''
    title: 'Lorem ipsum dolor sit amet.'
,
  category: 'quote'
  data:
    title: 'Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet.'
    redirectUrl: 'http://jianliao.com'
,
  category: 'quote'
  data:
    text: '''
      <br/>newline1<br>

      <br><br><p>newline2</p>

      <br >newline3<br />newline4
    '''
    title: 'A super long title that does not have any meaning at all.'
,
  category: 'quote'
  data:
    text: '''
      <table>
        <thead>
          <tr>
            <th>Metrics&nbsp;&nbsp;</th>
            <th>3 week ago&nbsp;&nbsp;</th>
            <th>2 week ago&nbsp;&nbsp;</th>
            <th>Last week&nbsp;&nbsp;</th>
            <th>Yesterday&nbsp;&nbsp;</th>
            <th>Comparison</th>
          </tr>
        </thead>
        <tbody>

          <tr>
            <td>active user</td>
              <td style='text-align: right'>27242&nbsp;&nbsp;</td>
              <td style='text-align: right'>27557&nbsp;&nbsp;</td>
              <td style='text-align: right'>27936&nbsp;&nbsp;</td>
              <td style='text-align: right'>27935&nbsp;&nbsp;</td>
              <td style="color: green; text-align: right">1.3%</td>
          </tr>

          <tr>
            <td>new user</td>
              <td style='text-align: right'>2007&nbsp;&nbsp;</td>
              <td style='text-align: right'>2005&nbsp;&nbsp;</td>
              <td style='text-align: right'>1944&nbsp;&nbsp;</td>
              <td style='text-align: right'>1853&nbsp;&nbsp;</td>
              <td style="color: red; text-align: right">-6.7%</td>
          </tr>

        </tbody>
      </table>
    '''
    title: 'A super long title that does not have any meaning at all.'
,
## rtf ##
  category: 'rtf'
  data:
    text: '</div></h2><script>alert(1)</scirpt>this is a broken html
      <p> this is a paragraph</p><p>this is another paragraph </p>
      <img></img>
      <ul><li>aaa</li><li>bbb</li></ul>
      '
    title: 'Lorem ipsum dolor sit amet.'
## speech ##
,
  category: 'speech'
  data:
    source: 'http://www.alexkatz.me/codepen/music/interlude.mp3'
,
  category: 'speech'
  data:
    source: 'http://www.alexkatz.me/codepen/music/interlude.mp3'
]
