function Total_containers=container_calculation(PBQ_name,Load)

for i=1:length(PBQ_name)
    if PBQ_name(i)=="Container Quay"
        Total_containers(i)=Load(i)/28; % This value 28 is given by Eurogate.. normally one container contains load of 25-28 tons
    else
        Total_containers(i)=0;
    end
end