# Section1
## Section1.1: What is Container
- Container和host的資源是共用的，不同於VM

## Section1.2: Install Docker in VMs
- 安裝2台VM，並在VM裡面安裝Docker: 請參考 https://medium.com/p/f3528b8154aa

## Section1.3: Pull/Save/Delete images
- 拉3個image: nginx, redis, mysql
    `$> docker pull image_name`
- 存下這3個image: 
    `$> docker save nginx redis mysql > all.tar`
- 刪除所有img腳本
    ```bash
    # rm_all_img.sh. A script to rm all images
    file=$(mktemp)
    docker images | grep -v REPOSITORY | awk '{print $1":"$2}' >> $file
    while read line; do
        docker rmi $line
    done < $file
    ```
    then `$> bash rm_all_img.sh`
- 載入所有imgs:
    `$> docker load -i all.tar`

## Section1.4: Create/Delete Container
```
$> docker run centos
$> docker ps  # show nothing, centos container have existed
$> docker ps -a  # show all container, you will see the existed centos container
$> docker rm {container_id}/{container_name}
```

```
# create container with environment variable
$> docker run -it --name=c1 --rm -e aa=123 -e bb=234 centos
root@centor$> echo $aa  # show 123
root@centor$> bash 
root@centor$> echo $aa  # show 123
root@centor$> echo $bb  # show 234
```


