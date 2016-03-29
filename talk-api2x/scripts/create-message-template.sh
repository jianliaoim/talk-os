#!/bin/bash
# 创建消息索引模板

curl -XPUT localhost:9200/_template/talk_messages -d '
{
  "template": "talk_messages_*",
  "mappings": {
    "messages": {
      "properties": {
        "_creatorId": {
          "type": "string",
          "index": "not_analyzed"
        },
        "_roomId": {
          "type": "string",
          "index": "not_analyzed"
        },
        "_storyId": {
          "type": "string",
          "index": "not_analyzed"
        },
        "_teamId": {
          "type": "string",
          "index": "not_analyzed"
        },
        "_toId": {
          "type": "string",
          "index": "not_analyzed"
        },
        "attachments": {
          "properties": {
            "category": {
              "type": "string",
              "index": "not_analyzed"
            },
            "data": {
              "properties": {
                "category": {
                  "type": "string",
                  "index": "not_analyzed"
                },
                "codeType": {
                  "type": "string",
                  "index": "not_analyzed"
                },
                "duration": {
                  "type": "long"
                },
                "fileCategory": {
                  "type": "string",
                  "index": "not_analyzed"
                },
                "fileName": {
                  "type": "string",
                  "term_vector": "with_positions_offsets",
                  "analyzer": "ik_max_word"
                },
                "fileSize": {
                  "type": "long"
                },
                "fileType": {
                  "type": "string",
                  "index": "not_analyzed"
                },
                "text": {
                  "type": "string",
                  "term_vector": "with_positions_offsets",
                  "analyzer": "ik_smart"
                },
                "title": {
                  "type": "string",
                  "term_vector": "with_positions_offsets",
                  "analyzer": "ik_max_word"
                },
                "remindAt": {
                  "type": "date",
                  "format": "dateOptionalTime"
                }
              }
            }
          }
        },
        "body": {
          "type": "string",
          "term_vector": "with_positions_offsets",
          "analyzer": "ik_max_word"
        },
        "createdAt": {
          "type": "date",
          "format": "dateOptionalTime"
        },
        "tags": {
          "properties": {
            "_tagId": {
              "type": "string",
              "index": "not_analyzed"
            },
            "name": {
              "type": "string",
              "term_vector": "with_positions_offsets",
              "analyzer": "ik_max_word"
            }
          }
        },
        "updatedAt": {
          "type": "date",
          "format": "dateOptionalTime"
        }
      }
    }
  },
  "settings": {
    "index": {
      "analysis": {
        "analyzer": {
          "ik_smart": {
            "type": "ik",
            "use_smart": "true"
          },
          "ik": {
            "type": "org.elasticsearch.index.analysis.IkAnalyzerProvider",
            "alias": [
              "ik_analyzer"
            ]
          },
          "ik_max_word": {
            "type": "ik",
            "use_smart": "false"
          }
        }
      },
      "number_of_shards": "5",
      "number_of_replicas": "1"
    }
  }
}
'
