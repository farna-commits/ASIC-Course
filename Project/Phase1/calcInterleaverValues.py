def floor_k_over_16():
    list = []
    for k in range (192):
        list.append(k // 16) 
    return list     

def kmod16_x_12(): 
    kmod16 = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    list = []
    for _ in range (12):
        list1 = []
        for i in kmod16:
            list1.append(12 * i)
        list.append(list1)
    list1 = []
    list1 = [y for x in list for y in x]
    return list1

def mk():
    import numpy as np 
    list1 = floor_k_over_16()
    list2 = kmod16_x_12()
    list1 = np.array(list1)
    list2 = np.array(list2)
    sumlists = list1 + list2
    return sumlists

    

def main():
    print(f"The floor(k/16) array is: {floor_k_over_16()}\n, with length of: {len(floor_k_over_16())}\n\n")
    print(f"The 192/16 * kmod16 array is: {kmod16_x_12()},\n with length of: {len(kmod16_x_12())}\n\n")
    print(f"The final mk array is: {mk().tolist()},\n with length of: {len(mk())}")


if __name__ == "__main__": 
    main()