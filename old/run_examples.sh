cd data
printf "\n*********************************************************************\nPress a key and then will run : h5ex_d_alloc"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_d_alloc
printf "\n*********************************************************************\nPress a key and then will run : h5ex_d_chunk"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_d_chunk
printf "\n*********************************************************************\nPress a key and then will run : h5ex_d_szip (will fail if szip filter not installed"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_d_szip
printf "\n*********************************************************************\nPress a key and then will run : h5_write"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_write
printf "\n*********************************************************************\nPress a key and then will run : h5_read"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_read
printf "\n*********************************************************************\nPress a key and then will run : h5_attribute"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_attribute
printf "\n*********************************************************************\nPress a key and then will run : h5_extend_write"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_extend_write
printf "\n*********************************************************************\nPress a key and then will run : h5_chunk_read"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_chunk_read
printf "\n*********************************************************************\nPress a key and then will run : h5_compound"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_compound
printf "\n*********************************************************************\nPress a key and then will run : h5_group"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5_group
printf "\n*********************************************************************\nPress a key and then will run : traits"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/traits
printf "\n*********************************************************************\nPress a key and then will run : myiterator"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/myiterator
printf "\n*********************************************************************\nPress a key and then will run : h5ex_t_bit"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_t_bit
printf "\n*********************************************************************\nPress a key and then will run : h5ex_t_stringatt"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_t_stringatt
printf "\n*********************************************************************\nPress a key and then will run : h5ex_t_string"
printf "\n**********************************************************************\n\n"
read -n 1 -s
../build/h5ex_t_string
cd ..
